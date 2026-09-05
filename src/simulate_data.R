# Simulation design

set.seed(3)
n<- 9850 #number of normal temp observations
n_a <- 150 # number of anomaly temp observations
mu <- 67 # mean temperature
sd <- 1 # Standard deviation of mean
k<- 5 # number of anomaly episodes
threshold<- 90
# Generating normal data

x_og<- rnorm(n,mu,sd)

# Generating anomaly data
seq_1.1<- seq(69, 91.52, length.out= 15)
seq_1.2 <- seq(90.49, 68.33, length.out= 15)
seq_1 <- c(seq_1.1, seq_1.2)
seq_1

seq_2.1<- seq(67.54, 93.52, length.out= 15)
seq_2.2 <- seq(93.49, 66.33, length.out= 15)
seq_2 <- c(seq_2.1, seq_2.2)

seq_3.1<- seq(68.5, 90.52, length.out= 15)
seq_3.2 <- seq(90.49, 69.73, length.out= 15)
seq_3 <- c(seq_3.1, seq_3.2)

seq_4.1<- seq(67, 92, length.out= 15)
seq_4.2 <- seq(91.349, 66.4, length.out= 15)
seq_4 <- c(seq_4.1, seq_4.2)

seq_5.1<- seq(69.5, 93.52, length.out= 15)
seq_5.2 <- seq(92.49, 66.33, length.out= 15)
seq_5 <- c(seq_5.1, seq_5.2)

# fitting anomalies to normal data

x<-c(x_og[1:2199],seq_1, x_og[2200:3099], seq_2, x_og[3100:4899], seq_3, x_og[4900:7399], seq_4, x_og[7400:8199], seq_5, x_og[8200:9850])
length(x)

# Converting vector to dataframe
df<- data.frame(x)
df$label <- df$x > threshold
colnames(df)<-c('Temperature(in celsius)','Label')
df

# Exporting Data
#write.csv(df, "C:\\Users\\READY\\Documents\\jupyter projects\\gpu-anomaly-detection\\Data\\telemetry_data.csv", row.names=FALSE)
#write.csv(x_og, "C:\\Users\\READY\\Documents\\jupyter projects\\gpu-anomaly-detection\\Data\\normal_data.csv", row.names=FALSE)

