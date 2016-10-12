import UIKit
import RxSwift

import SnapKit

extension UILabel {
    class func createLabel(text: String, fontSize: CGFloat = 20) -> UILabel {
        let label = UILabel()
        
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.blackColor()
        label.font = UIFont.systemFontOfSize(fontSize)
        label.text = text
        
        return label
    }
}

class CardViewPresenter {
    let cardView = CardView()
    
    lazy var startTimeValue = {
        UILabel.createLabel("21:32")
    }()
    
    let startTimeTitle = {
        UILabel.createLabel("Start Time", fontSize: 14)
    }()
    
    let lastUpdatedValue = {
        UILabel.createLabel("22:08")
    }()
    
    let lastUpdatedTitle = {
        UILabel.createLabel("Last Updated Time", fontSize: 14)
    }()
    
    let workoutLengthValue = {
        UILabel.createLabel("1h 20m")
    }()
    
    let workoutLengthTitle = {
        UILabel.createLabel("Workout Length", fontSize: 14)
    }()
    
    init() {
        cardView.backgroundColor = UIColor.whiteColor()
        cardView.addSubview(startTimeValue)
        cardView.addSubview(startTimeTitle)
        cardView.addSubview(lastUpdatedValue)
        cardView.addSubview(lastUpdatedTitle)
        cardView.addSubview(workoutLengthValue)
        cardView.addSubview(workoutLengthTitle)
    }
    
    func constraints(topOf: UIView, leadingTrailingTo: UIView) {
        cardView.snp_makeConstraints { make in
            make.top.equalTo(topOf.snp_bottom).offset(20)
            
            make.leading.equalTo(leadingTrailingTo).inset(20)
            make.trailing.equalTo(leadingTrailingTo).inset(20)
            
            make.height.equalTo(150)
        }
        
        startTimeValue.snp_makeConstraints { make in
            make.top.equalTo(cardView).inset(16)
            make.leading.equalTo(cardView).inset(16)
            make.width.equalTo(cardView.snp_width).dividedBy(2)
        }
        
        startTimeTitle.snp_makeConstraints { make in
            make.top.equalTo(startTimeValue.snp_bottom).offset(8)
            make.leading.equalTo(cardView).inset(16)
            make.width.equalTo(cardView.snp_width).dividedBy(2)
        }
        
        workoutLengthValue.snp_makeConstraints { make in
            make.top.equalTo(startTimeTitle.snp_bottom).offset(16)
            make.leading.equalTo(cardView).inset(16)
            make.width.equalTo(cardView.snp_width).dividedBy(2)
        }
        
        workoutLengthTitle.snp_makeConstraints { make in
            make.top.equalTo(workoutLengthValue.snp_bottom).offset(8)
            make.leading.equalTo(cardView).inset(16)
            make.width.equalTo(cardView.snp_width).dividedBy(2)
        }
        
        lastUpdatedValue.snp_makeConstraints { make in
            make.top.equalTo(cardView).inset(16)
            make.trailing.equalTo(cardView)
            make.width.equalTo(cardView.snp_width).dividedBy(2)
        }
        
        lastUpdatedTitle.snp_makeConstraints { make in
            make.top.equalTo(lastUpdatedValue.snp_bottom).offset(8)
            make.trailing.equalTo(cardView)
            make.width.equalTo(cardView.snp_width).dividedBy(2)
        }

    }
}

class MyViewController: UIViewController {
    var didSetupConstraints = false
    
    let scrollView  = UIScrollView()
    let contentView = UIView()
    let backgroundView = UIView()
    
    let cardViewPresenter = CardViewPresenter()
    let cp2 = CardViewPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backgroundGrey()
        view.addSubview(scrollView)
        
        contentView.backgroundColor = UIColor.backgroundGrey()
        backgroundView.backgroundColor = UIColor.primary()
        
        scrollView.addSubview(contentView)
        contentView.addSubview(backgroundView)
        contentView.addSubview(cardViewPresenter.cardView)
        contentView.addSubview(cp2.cardView)
        
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        if (!didSetupConstraints) {
            scrollView.snp_makeConstraints { make in
                make.edges.equalTo(view).inset(UIEdgeInsetsZero)
            }
            
            contentView.snp_makeConstraints { make in
                make.edges.equalTo(scrollView).inset(UIEdgeInsetsZero)
                make.width.equalTo(scrollView)
            }
            
            backgroundView.snp_makeConstraints { make in
                make.top.equalTo(contentView).inset(0)
                make.leading.equalTo(contentView).inset(0)
                make.trailing.equalTo(contentView).inset(0)
                make.height.equalTo(100)
            }
            
            self.cardViewPresenter.constraints(self.contentView, leadingTrailingTo: self.contentView)
            self.cp2.constraints(self.cardViewPresenter.cardView, leadingTrailingTo: self.contentView)
            
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
}

class HomeViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var totalWorkouts: UILabel!
    @IBOutlet weak var lastWorkout: UILabel!
    @IBOutlet weak var last7Days: UILabel!
    @IBOutlet weak var last31Days: UILabel!
    
    init() {
        super.init(nibName: "HomeView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()

        self.stackView.axis = UILayoutConstraintAxis.Vertical;
        self.stackView.distribution = UIStackViewDistribution.EqualSpacing;
        self.stackView.alignment = UIStackViewAlignment.Top;
        self.stackView.spacing = 0;

        _ = RoutineStream.sharedInstance.repositoryObservable().subscribeNext({ (it) in
            self.renderWorkoutProgressView()
            self.renderStatisticsView()
        })

        _ = RoutineStream.sharedInstance.routineObservable().subscribeNext({ (it) in
            self.renderWorkoutProgressView()
            self.renderStatisticsView()
            
            self.tabBarController?.title = it.title
        })
        
        self.showViewController(MyViewController(), sender: nil)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "plus"),
                landscapeImagePhone: nil,
                style: .Plain,
                target: self,
                action: #selector(routine))

        self.tabBarController?.title = "Bodyweight Fitness"
    }

    func renderWorkoutProgressView() {
        let routine = RoutineStream.sharedInstance.routine

        self.stackView.removeAllSubviews()
        self.navigationItem.title = routine.title

        if (RepositoryStream.sharedInstance.repositoryRoutineForTodayExists()) {
            let repositoryRoutine = RepositoryStream.sharedInstance.getRepositoryRoutineForToday()

            for category in repositoryRoutine.categories {
                let completionRate = RepositoryCategoryHelper.getCompletionRate(category)
                let homeBarView = HomeBarView()

                homeBarView.categoryTitle.text = category.title
                homeBarView.progressView.setCompletionRate(completionRate)
                homeBarView.progressRate.text = completionRate.label

                self.stackView.addArrangedSubview(homeBarView)
            }
        } else {
            for category in routine.categories {
                if let c = category as? Category {
                    let completionRate = CompletionRate(percentage: 0, label: "0%")
                    let homeBarView = HomeBarView()

                    homeBarView.categoryTitle.text = c.title
                    homeBarView.progressView.setCompletionRate(completionRate)
                    homeBarView.progressRate.text = completionRate.label

                    self.stackView.addArrangedSubview(homeBarView)
                }
            }
        }
    }

    func renderStatisticsView() {
        let numberOfWorkouts = RepositoryStream.sharedInstance.getNumberOfWorkouts()
        let lastWorkout = RepositoryStream.sharedInstance.getLastWorkout()

        let numberOfWorkoutsLast7Days = RepositoryStream.sharedInstance.getNumberOfWorkouts(-7)
        let numberOfWorkoutsLast31Days = RepositoryStream.sharedInstance.getNumberOfWorkouts(-31)

        self.totalWorkouts.text = String(numberOfWorkouts) + getNumberOfWorkoutsPostfix(numberOfWorkouts)

        if let w = lastWorkout {
            self.lastWorkout.text = String(NSDate.timeAgoSince(w.startTime))
        } else {
            self.lastWorkout.text = String("Never")
        }

        self.last7Days.text = String(numberOfWorkoutsLast7Days) + getNumberOfWorkoutsPostfix(numberOfWorkoutsLast7Days)
        self.last31Days.text = String(numberOfWorkoutsLast31Days) + getNumberOfWorkoutsPostfix(numberOfWorkoutsLast31Days)
    }

    func getNumberOfWorkoutsPostfix(count: Int) -> String {
        if (count == 1) {
            return " Workout"
        } else {
            return " Workouts"
        }
    }
    
    func routine(sender: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: "Choose Workout Routine",
            message: nil,
            preferredStyle: .ActionSheet)

        alertController.modalPresentationStyle = .Popover
        alertController.popoverPresentationController?.barButtonItem = sender;
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Bodyweight Fitness", style: .Default) { (action) in
            RoutineStream.sharedInstance.setRoutine("routine0")
        })
        
        alertController.addAction(UIAlertAction(title: "Molding Mobility", style: .Default) { (action) in
            RoutineStream.sharedInstance.setRoutine("e73593f4-ee17-4b9b-912a-87fa3625f63d")
        })
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func startWorkout(sender: AnyObject) {
        let backItem = UIBarButtonItem()
        backItem.title = "Home"

        self.tabBarController?.navigationItem.backBarButtonItem = backItem
        self.showViewController(WorkoutViewController(), sender: nil)
    }
}
