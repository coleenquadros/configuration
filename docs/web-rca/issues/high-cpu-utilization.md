# High CPU Utilization on WebRCA database instance

# RDSHighCPUUtilization:


“As per best practices and standards, continuous CPU Utilization above 80% suggests that the instance is CPU constraint. At this point users may look into Performance Insights and want to tune queries using maximum CPU. If the CPU Utilization continues to remain high even after queries are tuned, it may be an indication to increase the CPU power of the RDS Instance. Alternatively, if the CPU Utilization is consistently below 20%, users may think about reducing the compute capacity of the RDS instance by scaling-down the instance type to reduce cost.” (from https://aws.amazon.com/blogs/database/part1-best-practices-on-how-to-configure-monitoring-and-alerts-for-amazon-rds-for-sql-server/)

“CPUUtilizationshows the percent utilization of CPU at the instance. Random spikes in CPU consumption may not hamper database performance, but sustained high CPU can hinder upcoming database requests. Depending on the overall database workload, high CPU (70%–90%) at your Amazon RDS instance can degrade the overall performance.” (from https://aws.amazon.com/blogs/database/making-better-decisions-about-amazon-rds-with-amazon-cloudwatch-metrics/)



The CloudWatch graph below shows a sawtooth pattern of high CPU utilization indicating the CPU utilization remains consistently high for a long duration. 
This pattern is a good indication the Amazon RDS instance should be upgraded to a higher instance class.


![img.png](img.png)
