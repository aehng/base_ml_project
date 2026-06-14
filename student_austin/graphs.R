#Graphs for Neural Net

library(tidyverse)
library(pander)

predictions <- read_csv("real-big-motion-predictions.csv")

holdout <- read_csv("https://raw.githubusercontent.com/byui-cse/cse450-course/master/data/bikes_december.csv")

training <- read_csv("https://raw.githubusercontent.com/byui-cse/cse450-course/master/data/bikes.csv")

holdout1 <- holdout %>% 
  mutate(index = row_number())

edit <- predictions %>% 
  mutate(index = row_number())

edit2 <- edit %>% 
  filter(index < 301)

edit3 <- edit %>% 
  filter(index > 800) %>% 
  filter(index < 1101)

both <- holdout1 %>% 
  left_join(edit, by = "index")

hour_groups <- both %>% 
  group_by(hr) %>% 
  summarise(avg = mean(predictions, na.rm = TRUE))

train_groups <- training %>%
  mutate(total = casual + registered) %>% 
  group_by(hr) %>% 
  summarise(avg = mean(total, na.rm = TRUE)) 
  

ggplot(edit2, aes(x = index, y = predictions)) +
  geom_line(color = "steelblue", lwd = 1) +
  annotate(
    "text",
    x = 235,
    y = 0,
    label = "Veteran's Day"
  ) +
  annotate(
    "text",
    x = 100,
    y = 0,
    label = "Weekend"
  ) +
  labs(
    x = "Hour (starting 11/1/23)",
    y = "Model Prediction Total Rentals",
    title = "Neural Net Flexibility Visualized"
  ) +
  theme_bw()

# $10 per hour, but let's bump the price during spikes up by 15% and the price from troughs to be down 10%
#Weekdays: 7-9 and 4-7, then discount from 9-4
#Weekends: 11-5
#Holidays: all day discount? Idk
#Has to be 125% of daily average to kick in 15% price increase

prices <- both %>% 
  mutate(
    est_rev = predictions*10,
    #adjusted_rev = ifelse(predictions)
    ) %>% 
  filter(dteday == "11/1/2023")

idea <- both %>% 
  group_by(dteday) %>% 
  summarise(daily_avg = mean(predictions, na.rm = TRUE))

more_idea <- both %>% 
  left_join(idea, by = "dteday") %>% 
  mutate(
    base_rev = predictions*10,
    adjusted_rev = ifelse(predictions >= daily_avg, 1.15*base_rev, base_rev),
    date = mdy(dteday),
    datetime = date + hours(hr)
  )

cumsums <- more_idea %>% 
  mutate(
    cum_base = cumsum(base_rev),
    cum_adj = cumsum(adjusted_rev)
  ) %>% 
  select(datetime, cum_base, cum_adj) %>% 
  pivot_longer(
    cols = c(cum_base, cum_adj),
    names_to = "pricing",
    values_to = "cum_revenue"
  )

ggplot(cumsums, aes(x = datetime, y = cum_revenue, color = pricing)) +
  geom_line(lwd = 1) +
  scale_y_continuous(labels = scales::label_dollar()) +
  annotate(
    "text",
    x = mdy("12/6/2023"),
    y = 5500000,
    label = "Adaptive Pricing of 15% During Spikes"
  ) +
  annotate(
    "text",
    x = mdy("12/15/2023"),
    y = 3500000,
    label = "Base Pricing"
  ) +
  labs(
    title = "$600,000 More Earned From Simulated Adaptive Pricing",
    x = "Date",
    y = "Total Cumulative Revenue",
    subtitle = "From Nov - Dec 2023."
  ) +
  theme_bw() +
  theme(legend.position = "none")

edit4 <- more_idea %>% 
  mutate(adaptive_pricing = 1.25 * daily_avg) %>% 
  filter(index < 301)

ggplot(edit4, aes(x = datetime, y = predictions)) +
  geom_line() +
  geom_line(aes(y = adaptive_pricing)) +
  theme_bw()
