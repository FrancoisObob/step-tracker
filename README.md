# Step Tracker
Step Tracker integrates Apple Health to show your latest step and weight data in animated, interactive Swift Charts. You can also see your average steps and weight gain/loss for each weekday for the past 28 days.

Step Tracker also allows you to upload new step or weight data to the Apple Health app.

# Technologies Used
* SwiftUI
* HealthKit
* Swift Charts
* Swift Algorithms
* DocC
* Git & GitHub

# Animated Swift Charts
https://github.com/user-attachments/assets/d60f27cf-3556-41df-9e35-fce0a8338d64



# I'm Most Proud Of...
The average weight difference per day of the week bar chart. Determining which day of the week were problem days for someone trying to lose weight struck me as a great insight to surface from the weight data. 

I pulled the last 29 days of weights and ran a calculation to track the differences between each weekday. I then averaged each weekday's gain/loss and displayed them in a bar chart and conditionally colored the positive and negative weight change values.

Here's the code:

```swift
    var averageDailyWeightDiffsData: [DateValueChartData] {
        var diffValues: [(date: Date, value: Double)] = []

        guard self.count > 1 else { return [] }

        for i in 1..<self.count {
            let date = self[i].date
            let diff = self[i].value - self[i-1].value
            diffValues.append((date: date, value: diff))
        }

        return diffValues
            .sorted(using: KeyPathComparator(\.date.weekdayInt))
            .chunked { $0.date.weekdayInt == $1.date.weekdayInt }
            .map { .init(date: $0.first!.date,
                         value: $0.reduce(0) { $0 + $1.value } / Double($0.count))
            }
    }
```
<br>
</br>

![readme-weight-diff](https://github.com/user-attachments/assets/4a3cb68a-569e-4166-b240-f28979f6db74)


# Completeness
Although it's a simple portfolio project, I've implemented the following
* Error handling & alerts
* Empty states
* Permission Priming
* Text input validation
* Basic unit tests
* Basic accessibility
* Privacy Manifest
* Code documentation (DocC)
* Project organization


