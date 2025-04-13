# ==============================================
# Event Participation Analysis Script
# Student Information System
# ==============================================

# Load required libraries
library(ggplot2)  # For creating visualizations
library(dplyr)    # For data manipulation

# Set a clean, modern theme for all plots
theme_set(theme_minimal(base_size = 12))

# Read the event participation data
cat("\n===== Loading Data =====\n")
event_data <- read.csv("eventinfo.csv")
cat("Data loaded successfully!\n")

# ==============================================
# Initial Data Processing
# ==============================================
cat("\n===== Processing Data =====\n")

# Count participants per event
event_summary <- event_data %>%
  group_by(event_id) %>%
  summarise(
    participant_count = n(),
    .groups = 'drop'
  ) %>%
  arrange(desc(participant_count))

cat("Found", nrow(event_summary), "unique events in the dataset\n")

# ==============================================
# Visualization 1: Top 5 Most Popular Events
# ==============================================
cat("\n===== Visualization 1: Top 5 Most Popular Events =====\n")

# Prepare data for top 5 events
top_5_events <- head(event_summary, 5)

# Create bar chart
top_5_chart <- ggplot(top_5_events, 
                      aes(x = reorder(factor(event_id), -participant_count), 
                          y = participant_count)) +
  geom_bar(stat = "identity", fill = "#4e79a7", width = 0.7) +
  geom_text(aes(label = participant_count), 
            vjust = -0.5, 
            size = 4, 
            fontface = "bold") +
  labs(
    title = "Top 5 Most Popular Events",
    subtitle = "Based on Student Participation",
    x = "Event ID",
    y = "Number of Participants"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    axis.text = element_text(size = 10),
    panel.grid.major.x = element_blank()
  )

# Display the visualization
print(top_5_chart)

# Save the visualization
ggsave("top_5_events.png", top_5_chart, width = 10, height = 6, dpi = 300)
cat("Top 5 events chart has been saved as 'top_5_events.png'\n")

# ==============================================
# Visualization 2: Lollipop Chart
# ==============================================
cat("\n===== Visualization 2: Lollipop Chart of All Events =====\n")

# Create lollipop chart
lollipop_chart <- ggplot(event_summary, 
                         aes(x = reorder(factor(event_id), participant_count), 
                             y = participant_count)) +
  geom_segment(aes(x = reorder(factor(event_id), participant_count), 
                   xend = reorder(factor(event_id), participant_count),
                   y = 0, 
                   yend = participant_count),
               color = "#b3b3b3", size = 0.8) +
  geom_point(color = "#4e79a7", size = 4) +
  geom_text(aes(label = participant_count),
            vjust = -0.8,
            color = "#2b2b2b") +
  coord_flip() +
  labs(
    title = "Event Participation Distribution",
    subtitle = "Number of Students per Event",
    x = "Event ID",
    y = "Number of Participants"
  ) +
  theme(
    plot.title = element_text(hjust = 0, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    panel.grid.major.y = element_blank()
  )

# Display the visualization
print(lollipop_chart)

# Save the visualization
ggsave("event_lollipop.png", lollipop_chart, width = 12, height = 8, dpi = 300)
cat("Lollipop chart has been saved as 'event_lollipop.png'\n")

# ==============================================
# Visualization 3: Donut Chart
# ==============================================
cat("\n===== Visualization 3: Donut Chart of Event Distribution =====\n")

# Prepare data for donut chart
event_percentages <- event_summary %>%
  mutate(
    percentage = participant_count / sum(participant_count) * 100,
    label = paste0(round(percentage, 1), "%"),
    position = cumsum(percentage) - percentage/2
  )

# Create donut chart
donut_chart <- ggplot(event_percentages, 
                      aes(x = 2, y = percentage, fill = factor(event_id))) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar(theta = "y", start = 0) +
  geom_text(aes(x = 2.5, y = position, label = label),
            size = 3.5) +
  scale_fill_brewer(palette = "Set3") +
  xlim(0.5, 2.5) +
  labs(
    title = "Event Participation Distribution",
    subtitle = "Percentage Share by Event",
    fill = "Event ID"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank()
  )

# Display the visualization
print(donut_chart)

# Save the visualization
ggsave("event_donut.png", donut_chart, width = 10, height = 10, dpi = 300)
cat("Donut chart has been saved as 'event_donut.png'\n")

# ==============================================
# Visualization 4: Summary Table
# ==============================================
cat("\n===== Visualization 4: Top 3 Events Summary =====\n")

# Create summary table
top_3_summary <- head(event_summary, 3) %>%
  mutate(
    percentage = round(participant_count / sum(event_summary$participant_count) * 100, 1),
    summary = paste0("Event ", event_id, ": ", participant_count, 
                     " participants (", percentage, "%)")
  ) %>%
  select(summary)

# Display summary statistics
cat("\nEvent Participation Summary:")
cat("\n--------------------------\n")
cat("Total Events:", nrow(event_summary))
cat("\nTotal Participants:", sum(event_summary$participant_count))
cat("\n\nTop 3 Most Popular Events:\n")
print(top_3_summary)

# ==============================================
# Final Summary
# ==============================================
cat("\n===== Visualization Summary =====\n")
cat("All visualizations have been generated and saved:\n")
cat("1. Top 5 Events Bar Chart (top_5_events.png)\n")
cat("2. Event Participation Lollipop Chart (event_lollipop.png)\n")
cat("3. Event Distribution Donut Chart (event_donut.png)\n")
cat("4. Top 3 Events Summary (displayed above)\n") 