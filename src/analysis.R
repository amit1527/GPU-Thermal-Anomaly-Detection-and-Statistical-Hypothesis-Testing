# Importing telemetry
df<- read.csv("C:\\Users\\READY\\Documents\\jupyter projects\\gpu-anomaly-detection\\Data\\telemetry_data.csv")
x_og<- read.csv("C:\\Users\\READY\\Documents\\jupyter projects\\gpu-anomaly-detection\\Data\\normal_data.csv")
x_anomaly <- df$Temperature.in.celsius.
x<- x_og$x
threshold<- 90

# Anomaly Episodes
ep_1 <- seq(2200,2229)
ep_2 <-seq(3130,3159)
ep_3 <-seq(4960,4989)
ep_4 <-seq(7490,7519)
ep_5 <-seq(8320,8349)
anomaly_ep <- c(ep_1,ep_2,ep_3,ep_4,ep_5)
# Plotting
## Time-series plot — temperature vs observation/time

plot_1 <- plot(seq(length(df$Temperature.in.celsius.)),df$Temperature.in.celsius., type = "l", col = "blue", lwd = 2, main = "Title", xlab = "X Label", ylab = "Y Label")

## Histogram of temperature

plot_2<- hist(df$Temperature.in.celsius., breaks = 500, col = "skyblue", border = "blue", main = "Title", xlab = "X Label")

# Finding descriptive statisitic of data
summary(df$Temperature.in.celsius.)

# Indicator Alert
A<- c((df$Temperature.in.celsius.>threshold)*1)
plot_3 = plot(seq(length(df$Temperature.in.celsius.)),A,xlab = "X Label" , ylab = 'Threshold Alert' )

# Maximum Likelihood Estimation of mu and standard deviation

neg_likelihood <- function(par){
  mu <- par[1]
  sd<- par[2]
  
  if (sd <0) return(Inf)
  
  log.likelihood<- dnorm(x , mean = mu, sd=sd, log = TRUE)
  
  return(-sum(log.likelihood))
}

result <- optim(
  par = c(mu=0,sd=1),
  fn= neg_likelihood
)
mu <- result$par[1]
sd <- result$par[2]

# Calculating upper-tail probability
z<- (x_anomaly-mu)/sd
p <- pnorm(z,lower.tail = FALSE )
alpha <- 0.01 #Anomaly flag

# Creating a statistical Alert
statistical_alert <- c((p<alpha)*1)
df$statistical_alert <- statistical_alert

# Percentage of observations were flagged
anomaly.perc <- sum(df$statistical_alert)/length(df$Temperature.in.celsius.) * 100

# plotting statistical Alert
plot_4 <- plot(seq(length(df$Temperature.in.celsius.)), df$statistical_alert,xlab = "X Label",ylab = 'Statistical Alert')

# Ground truth indicator function
index<- sort(c(which(df$statistical_alert == 1),which(df$statistical_alert != 1) ))
ground.truth <- c((index %in% anomaly_ep)*1)
df$GroundTruth <- ground.truth


# Confusion Matrix for Statistical Alert
TP <- sum(c(((df$statistical_alert==1)&(df$GroundTruth==1))*1))
FN <- sum(c(((df$statistical_alert==0)&(df$GroundTruth==1))*1))
TN <- sum(c(((df$statistical_alert==0)&(df$GroundTruth==0))*1))
FP <- sum(c(((df$statistical_alert==1)&(df$GroundTruth==0))*1))

detection_rate<- TP/(TP+FN)
false_alarm_rate<- FP/(FP+TN)
detection_rate
false_alarm_rate

# Confusion Matrix for threshold Alert
TP_t <- sum(c(((df$Label==TRUE)&(df$GroundTruth==1))*1))
FN_t <- sum(c(((df$Label==FALSE)&(df$GroundTruth==1))*1))
TN_t <- sum(c(((df$Label==FALSE)&(df$GroundTruth==0))*1))
FP_t <- sum(c(((df$Label==TRUE)&(df$GroundTruth==0))*1))

detection_rate_t<- TP_t/(TP_t+FN_t)
false_alarm_rate_t<- FP_t/(FP_t+TN_t)
detection_rate_t
false_alarm_rate_t

# Creating Comparison DATAFRAME
df2<- data.frame(
  statistical_alert = c(TP,FN,TN,FP,detection_rate,false_alarm_rate),
  Threshold_alert = c(TP_t,FN_t,TN_t,FP_t,detection_rate_t, false_alarm_rate_t),
  row.names = c('TP','FN','TN','FP','Detection Rate','False Alarm Rate')
)
df2
