
dat.full <- as.data.frame(read.table('states_all.csv',header=TRUE,sep=','))

dat <- dat.full[seq(1,1280,1),]

View(dat)

year.15 <- dat[dat$YEAR=='2015',]
View(year.15)

# Remove primary key, state, and year for this
df.model <- as.data.frame(year.15[-c(1,2,3)])

View(df.model)


# Remove extra scores
df.model$AVG_MATH_4_SCORE <- NULL
df.model$AVG_MATH_8_SCORE <- NULL
df.model$AVG_READING_4_SCORE <- NULL
df.model$AVG_READING_8_SCORE <- NULL


View(df.model)

# Remove any rows with missing data
cleaned.model.dat <- na.omit(df.model)

View(cleaned.model.dat)

# Remove DC since it has no state revenue
cleaned.model.dat <- cleaned.model.dat[-8,]

scaled.dat <- as.data.frame(scale(cleaned.model.dat))

response <- (scaled.dat$AVG_READING_4_SCORE+scaled.dat$AVG_READING_8_SCORE+scaled.dat$AVG_MATH_4_SCORE+scaled.dat$AVG_MATH_8_SCORE)/4

model <- lm(response~INSTRUCTION_EXPENDITURE+ENROLL,data=cleaned.model.dat)

plot(scaled.dat$ENROLL,response)

summary(model)

model$coefficients
