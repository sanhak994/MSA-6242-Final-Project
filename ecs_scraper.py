"""
ecs_scraper.py
Author: Fred Sackfield
Date Created: 11-18-2019
Description: Module that scrapes state legislation data from the ECS
            (Education Commission of the States) website. 
"""

from bs4 import BeautifulSoup
import urllib
import requests
import pypyodbc
import datetime
import time
from time import sleep
import re

#sql connection
connection = pypyodbc.connect(driver='{SQL Server}',server='localhost\SQLEXPRESS', database='CSE6242', trusted_connection='yes')
cursorInsert = connection.cursor()

#sql command - to be executed with scraped values
SQLInsertCommand = ('INSERT INTO dbo.States_Legislation '+
                    '(stateAbbr, subtopic, [level], title, status, [date]) '+
                    'VALUES (?,?,?,?,?,?)')

#headers for url request
headers = {'user-agent':
           'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36'}

base_url = 'https://www.ecs.org/state-legislation-by-topic/'
base_page = requests.get(base_url, headers=headers, timeout=10)
base_soup = BeautifulSoup(base_page.text, 'html.parser')

#a_soup contains all of the "sub-topic" urls from which we will scrape data
a_soup = base_soup.find_all('p')[2].find_all('a')

#loop through all sub-topics
for a in a_soup:
    count = 0
    sleep(2) #sleep because we are polite crawlers
    
    topic_name = a.text
    topic_page = requests.get(a.attrs['href'], headers=headers, timeout=10)
    topic_soup = BeautifulSoup(topic_page.text,'html.parser')
    print('Got soup for '+topic_name)
    
    #get all data rows from the current page
    rows = topic_soup.find('body').find_all('tr')

    #check if this is a multi-page subtopic
    multipage = topic_soup.find('a',{'data-cb-name':'JumpToNext'}) is not None
    #if so, add rows from the next page(s)
    if multipage == True:
        print('Appending more rows')
        nextpage = requests.get(topic_soup.find('a',{'data-cb-name':'JumpToNext'}).attrs['href'],headers=headers)
        nextpagesoup = BeautifulSoup(nextpage.text,'html.parser')  
        for row in nextpagesoup.find('body').find_all('tr'):
            if 'id' in row.attrs:
                rows.append(row)

        multi2page = nextpagesoup.find('a',{'data-cb-name':'JumpToNext'}) is not None
        if multi2page == True:
            next2page = requests.get(nextpagesoup.find('a',{'data-cb-name':'JumpToNext'}).attrs['href'],headers=headers)
            next2pagesoup = BeautifulSoup(next2page.text,'html.parser')
            for row in next2pagesoup.find('body').find_all('tr'):
                if 'id' in row.attrs:
                    rows.append(row)
                    
    #loop through the data rows and insert into sql db
    for row in rows:
        if 'id' in row.attrs:
            count += 1
            td1 = row.find('td').text
            if re.search(r'\d\d\d\d-\d\d-\d\d',td1) is None:
                continue
            hyph = re.search(r'\d\d\d\d-\d\d-\d\d',td1).span()[0]+4
            
            status = td1[:hyph-4]
            date = td1[hyph-4:len(td1)]
            state_abbr = row.find('td').find_next('td').text
            level = row.find('td').find_next('td').find_next('td').text
            title = row.find('td').find_next('td').find_next('td').find_next('td').text

            values = [state_abbr,topic_name,level,title,status,date]
            
            cursorInsert.execute(SQLInsertCommand, values)
            connection.commit()
    print('Import for topic '+topic_name+' ('+str(count)+' rows) committed.')

connection.close()
            







    

