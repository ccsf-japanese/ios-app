import UIKit
import ChameleonFramework

protocol KanjiDrawingDataSource: class {
  var nextStrokeIndex: Int { get }
  var character: Character? { get }
  var kanjiTransform: CGAffineTransform? { get }
  
}

protocol KanjiViewControllerDelegate: class {
  func kanjiViewController(kanjiViewController: KanjiViewController, didFinishDrawingKanji character: Character)
}

class KanjiViewController: UIViewController, KanjiDrawingDataSource, DrawKanjiViewDelegate {
  
  var level: Level?
  
  @IBOutlet weak var kanjiView: KanjiView!
  @IBOutlet weak var drawKanjiView: DrawKanjiView!
  
  @IBOutlet weak var titleButton: UIButton!
    
  weak var delegate: KanjiViewControllerDelegate?
  
  let undoButton = UIButton(type: .System)
  let clearButton = UIButton(type: .System)
  let meaningLabel = UILabel()
  
  var nextStrokeIndex = 0 {
    didSet {
      kanjiView.setNeedsDisplay()
    }
  }
  var character: Character? {
    didSet {
      nextStrokeIndex = 0
      meaningLabel.text = ""
      kanjiView.setNeedsDisplay()
    }
  }
  var kanjiTransform: CGAffineTransform? {
    didSet {
      kanjiView.setNeedsDisplay()
    }
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    view.addSubview(undoButton)
    view.addSubview(clearButton)
    view.addSubview(meaningLabel)
    
    //undoButton.setTitle("Undo", forState:.Normal)
    undoButton.setImage(UIImage.init(named: "ic_undo"), forState: .Normal)
    //clearButton.setTitle("Clear", forState:.Normal)
    clearButton.setImage(UIImage.init(named: "ic_clear"), forState: .Normal)
    
    undoButton.titleLabel?.font = UIFont.systemFontOfSize(26)
    clearButton.titleLabel?.font = UIFont.systemFontOfSize(26)
    meaningLabel.font = UIFont.systemFontOfSize(26)

    
    undoButton.translatesAutoresizingMaskIntoConstraints = false
    
    undoButton.addTarget(self, action: "undoButtonTapped", forControlEvents: .TouchUpInside)
    
    clearButton.translatesAutoresizingMaskIntoConstraints = false
    clearButton.addTarget(self, action: "clearButtonTapped", forControlEvents: .TouchUpInside)
    
    meaningLabel.translatesAutoresizingMaskIntoConstraints = false
    meaningLabel.textColor = FlatPlumDark()
    meaningLabel.textAlignment = .Center
    meaningLabel.numberOfLines = 3

    //undoButton constraints
    NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: undoButton, attribute: .Leading, multiplier: 1.0, constant: -15.0).active = true
    NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: undoButton, attribute: .Bottom, multiplier: 1.0, constant: 15.0).active = true
    
    //clearButton constraints
    NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: clearButton, attribute: .Trailing, multiplier: 1.0, constant: 15.0).active = true
    NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: clearButton, attribute: .Bottom, multiplier: 1.0, constant: 15.0).active = true
    
    //meaningLabel constraints
    NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: meaningLabel, attribute: .Trailing, multiplier: 1.0, constant: 40.0).active = true
    NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: meaningLabel, attribute: .Leading, multiplier: 1.0, constant: -40.0).active = true
    NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: meaningLabel, attribute: .Bottom, multiplier: 1.0, constant: 15.0).active = true
    
    self.drawKanjiView.delegate = self
    self.kanjiView.dataSource = self
    self.drawKanjiView.dataSource = self
    
    if let level = self.level {
      let chosenCharacter = level.characters[0]
      JapanizeFileClient.sharedInstance.dataForFilePath(chosenCharacter.svgURL,
                                                        completion: { (data, error) in
        if let svgData = data {
          chosenCharacter.setStrokesWithSVG(svgData)
          print("Level character ready!")
          self.character = chosenCharacter
        } else {
          assertionFailure("error downloading SVG")
        }
      })
    } else {
      setNewRandomCharacter()
    }
  }
  
  func undoButtonTapped() {
    if nextStrokeIndex > 0 {
      nextStrokeIndex -= 1
    }
  }
  func clearButtonTapped() {
    nextStrokeIndex = 0
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

  override func viewWillAppear(animated: Bool) {
    //Theme Block
    let themeColor = UIColor(red: 142/255, green: 68/255, blue: 173/255, alpha: 1).flatten()
    let themeContrast = ContrastColorOf(themeColor, returnFlat: true)
    let nav = self.navigationController?.navigationBar
    self.navigationController?.hidesNavigationBarHairline = true
    nav?.barTintColor = themeColor
    nav?.tintColor =  themeContrast
    nav?.titleTextAttributes = [NSForegroundColorAttributeName: themeContrast]
    self.tabBarController?.tabBar.tintColor = themeColor
    //
  }
  
  override func viewDidLayoutSubviews() {
    let scale = min(kanjiView.frame.height, kanjiView.frame.width) / 109
    let transform = CGAffineTransformMakeScale(scale, scale)
    kanjiTransform = transform
  }
    
    func setTitle2Meaning(){
        print("setTitle to Meaning")
        if let character = character {
            if character.kind == "kanji" {
                self.titleButton.setTitle("漢字: \(character.meaning!)", forState: .Normal)
            } else if character.kind == "hiragana" {
                self.titleButton.setTitle("ひらがな: \(character.romaji!)", forState: .Normal)
            } else if character.kind == "katakana" {
                self.titleButton.setTitle("カタカナ: \(character.romaji!)", forState: .Normal)
            } else {
                self.titleButton.setTitle("Japanize", forState: .Normal)
                assertionFailure("unknown character kind")
            }
        }
    }
  
  func didCompleteStroke() {
    nextStrokeIndex += 1
    if let character = character {
      if let strokes = character.strokes {
        if nextStrokeIndex == strokes.count {
          if character.kind == "kanji" {
            meaningLabel.text = "\(character.meaning!) \n漢字"
          } else if character.kind == "hiragana" {
            meaningLabel.text = "'\(character.romaji!)' \nひらがな"
          } else if character.kind == "katakana" {
            meaningLabel.text = "'\(character.romaji!)' \nカタカナ"
          } else {
            assertionFailure("unknown character kind")
          }
          
          if let level = level {
            User.currentUser?.levelsComplete[level.id] = 1
            // TODO: Investigate how to save updated value automatically so we don't have to do this.
            User.currentUser! = User.currentUser!
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 2))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
              // TODO: Investigate how to save updated value automatically so we don't have to do this.
              User.currentUser?.score += 10
              User.currentUser! = User.currentUser!
            
              self.performSegueWithIdentifier("showPronuntiation", sender: level)
              
              //self.dismissViewControllerAnimated(false, completion: {
              //  print("Successfully completed level")
              //})
            }
          } else {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 2))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
              self.setNewRandomCharacter()
            }
          }
        }
      }
      
      delegate?.kanjiViewController(self, didFinishDrawingKanji: character)
    }
  }
  
  func setNewRandomCharacter() {
    // TODO: Consider refactoring nested code, adding error handling
    JapanizeClient.sharedInstance.book( { (book, error) -> () in
      if let book = book {
        var characters = Array<Character>()
        
        for chapter in book.chapters {
          for level in chapter.levels {
            for character in level.characters {
              characters.append(character)
            }
          }
        }
        
        let chosenCharacter = characters.sample()
        JapanizeFileClient.sharedInstance.dataForFilePath(chosenCharacter.svgURL,
          completion: { (data, error) in
            if let svgData = data {
              chosenCharacter.setStrokesWithSVG(svgData)
              print("Random character ready!")
              self.character = chosenCharacter
              self.setTitle2Meaning()
            } else {
              assertionFailure("error downloading SVG")
            }
        })
      }
    })
  }
    
  @IBAction func onNavigationBar(sender: AnyObject) {
    if titleButton.titleLabel?.text == "Japanize" {
        setTitle2Meaning()
    } else {
        titleButton.setTitle("Japanize", forState: .Normal)
    }
  }
    
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.becomeFirstResponder()
  }
    
  override func canBecomeFirstResponder() -> Bool {
    return true
  }
    
  override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent!) {
    if (event.subtype == UIEventSubtype.MotionShake && level == nil) {
      self.setNewRandomCharacter()
    }
  }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem

        if let level = sender as? Level {
            if let vc = segue.destinationViewController as? PronunciationViewController {
                vc.level = level
            } else if let vc = segue.destinationViewController as? KanjiViewController {
                vc.level = level
            } else {
                assertionFailure("Destination view controller unknown")
            }
        }
    }

}