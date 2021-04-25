//
//  ViewController.swift
//  HealthKitTestV1
//
//  Created by Tyler Boston on 4/14/21.
//
// MARK: Problems
    /// 1. Lines 95 & 97 have IBOutlets and can't get labelHR to update with heartrate result printed in debug console by pressing HRButton. HR Step 8: tries to modfiy the label but will only print out the query instance not result.


// MARK: To Do's
    /// 1. add distanceWalkingRunnin (or walkingSteps), and activeEnergyBurned to HK Step 3
    ///

// MARK: HealthKit Implementation
    /// HK Step 1: Establish the HKHealthStore
    /// HK Step 2: Call the function authorizing the collection of read + writing specifically stated healthkit data after super.viewDidLoad
    /// HK Step 3: create a function that authorizes the management of healthkit data
    /// HK Step 4: create a constant that allows pulling of specific data
    /// HK Step 5: create a constant that allows writing and sharing of specific data
    /// HK Step 6: Create the authorization request for the healthStore NSObject or in this isntance, HKHealthStore() to share objects and read objects and add possibilities

// MARK: HeartRate Retrieval
    /// HR Step 1: Create the function to pull latestHeartRate
    /// HR Step 2: Info needed from the HKStore (sampleType is heartRate)
    /// HR Step 3: This will help retrieve the records in a sorted descending order
    /// HR Step 4: Made to provide the date range necessary for the 'let predicate' statement below
    /// HR Step 5: Must create the date range to collect the information from
    /// HR Step 6: Instatiate the query with immutable objects and pass in the previously created parameters
    /// HR Step 7a: To be able to retrieve the results of the sampleType
    /// HR Step 7b: Must also define the units it counts in for ex. debug prints hr in counts/min
    /// HR Step 7c: Instantiating the call for
    /// HR Step 7d: Setting up date format
    /// HR Step 8: Must execute the query at the end of the function otherwise no results will come through

// MARK: Mindful Minutes Retrieval
    ///


import UIKit
import HealthKit




class ViewController: UIViewController {
    
    

    
  
    
    /* @IBOutlet weak var meditationMinutesLabel: UILabel!
    
    @IBAction func addMinuteAct(_ sender: Any) {
        // Create a start and end time 1 minute apart
       /* let startTime = Date() */
      /*  let endTime = startTime.addingTimeInterval(1.0 * 60.0) */
        
        /* self.saveMindfulAnalysis(startTime: startTime, endTime: endTime) */
    }*/
    
    /// HK Step 1:
    let healthStore = HKHealthStore()
    
    /// MM Step 1: Establish the mindfulType object which pulls the mindfulSession value
    let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    /// HK Step 2:
        authorizeHealthKit()
    }
    /// HK Step 3
    func authorizeHealthKit(){
        // add distanceWalkingRunnin (or walkingSteps), and activeEnergyBurned
    /// HK Step 4:
        let read = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                        HKObjectType.categoryType(forIdentifier: .mindfulSession)!])
        
    // HK Step 5:
        let share = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                         HKObjectType.categoryType(forIdentifier: .mindfulSession)!])
    
    // HK Step 6:
        healthStore.requestAuthorization(toShare: share, read: read) { (success, error) in if(success){
                print("Permission granted")
            self.latestHeartRate()
               /* self.retrieveMindfulMinutes()*/
            }
            
        }
    }
    

   
    @IBOutlet weak var labelHR: UILabel!
    
    @IBAction func HRButton(_ sender: Any) {
        latestHeartRate()
    }
    
    /// HR Step 1:
    func latestHeartRate() {
        
    /// HR Step 2:
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else{
            return
        }
        
    /// HR Step 3:
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    
    /// HR Step 4:
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
    
    /// HR Step 5:
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
    
        
       
    /// HR Step 6:
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: Int(HKObjectQueryNoLimit),
            sortDescriptors: [sortDescriptor]){ (sample, result, error) in
            guard error == nil else{
                return
            }
    /// HR Step 7a:
        let data = result![1] as! HKQuantitySample
    
    /// HR Step 7b:
        let unit = HKUnit(from: "count/min")
    
    /// HR Step 7c:
        let latestHr = data.quantity.doubleValue(for: unit)
        print("latest Hr \(latestHr) BPM")
            
    /// HR Step 7d:
        let dateFormator = DateFormatter()
        dateFormator.dateFormat = "MM/dd/yyyy hh:mm s"
        let StartDate = dateFormator.string(from: data.startDate)
        let EndDate = dateFormator.string(from: data.endDate)
        print("StartDate \(StartDate) : EndDate \(EndDate)")
        }
        
    /// HR Step 8:
        healthStore.execute(query)
        labelHR.text = "\(query)"
    }
/*
    func calculateTotalTime(sample: HKSample) -> TimeInterval {
        let totalTime = sample.endDate.timeIntervalSince(sample.startDate)
        let wasUserEntered = sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool ?? false
        
        print("\nHealthKit mindful entry: \(sample.startDate) \(sample.endDate) - value: \(totalTime) quantity: \(totalTime) user entered: \(wasUserEntered)\n")
        
            return totalTime
    }
    
    func updateMeditationTime(query: HKSampleQuery, results: [HKSample]?, error: Error?) {
        if error != nil {return}
        
        // Sum the meditation time
        let totalMeditationTime = results?.map(calculateTotalTime).reduce(0, { $0 + $1}) ?? 0
        
        print("\n Total: \(totalMeditationTime)")
        
        renderMeditationMinuteText(totalMeditationSeconds: totalMeditationTime)
    }
    
    func renderMeditationMinuteText(totalMeditationSeconds: Double) {
        let minutes = Int(totalMeditationSeconds / 60)
        let labelText = "\(minutes) Mineful Minutes in the last 24 hours"
        DispatchQueue.main.async {
            self.meditationMinutesLabel.text = labelText
        }
    }
    
    func retrieveMindfulMinutes(){

//MARK:Start HERE May not be necessary; the information from both the HR and MM could be combined to give the ability to read (and request in debug) and write data
    guard let sampleType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else{
        return
    }
        // Use a sortDescriptor to get the recent data first (optional)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        // Get all samples from the lat 24  hours
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-1.0 * 60.0 * 60.0 * 24.0) // (-) indicates past, sec, min, hrs
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        // Create the HealthKit Query
        let query = HKSampleQuery(
            sampleType: mindfulType!,
            predicate: predicate,
            limit: 0,
            sortDescriptors: [sortDescriptor],
            resultsHandler: updateMeditationTime)
        
        healthStore.execute(query)
    }

    func saveMindfulAnalysis(startTime: Date, endTime: Date) {
        // Create a mindful session with the given start and end time
        let mindfulSample = HKCategorySample(type: mindfulType!, value: 0, start: startTime, end: endTime)
        
        // Save it to the health store
        healthStore.save(mindfulSample, withCompletion:{ (success, error) -> Void in
            if error != nil {return}
            
            print("New data was saved in HealthKit: \(success)")
            self.retrieveMindfulMinutes()
        })
    }
*/
}
