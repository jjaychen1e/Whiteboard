//
//  ICSCalandar.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/31.
//

import Foundation

fileprivate struct ICSDateFormatter {
    private static let _dateFormatter = DateFormatter()
    
    static var dateFormatter: DateFormatter {
        get {
            _dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
            return _dateFormatter
        }
    }
}

fileprivate enum ICSTimeZone {
    case Asia_Shanghai
    
    func toString() -> String {
        switch self {
        case .Asia_Shanghai:
            return "Asia/Shanghai"
        }
    }
    
    func toICSDescription() -> String{
        switch self {
        case .Asia_Shanghai:
            return """
            X-WR-TIMEZONE:Asia/Shanghai
            CALSCALE:GREGORIAN
            BEGIN:VTIMEZONE
            TZID:Asia/Shanghai
            BEGIN:STANDARD
            TZOFFSETFROM:+0900
            RRULE:FREQ=YEARLY;UNTIL=19910914T170000Z;BYMONTH=9;BYDAY=3SU
            DTSTART:19890917T020000
            TZNAME:GMT+8
            TZOFFSETTO:+0800
            END:STANDARD
            BEGIN:DAYLIGHT
            TZOFFSETFROM:+0800
            DTSTART:19910414T020000
            TZNAME:GMT+8
            TZOFFSETTO:+0900
            RDATE:19910414T020000
            END:DAYLIGHT
            END:VTIMEZONE
            """
        }
    }
}

class ICSCalendar {
    var name: String
    
    var prodID: String = "jjacychen.me"
    
    private var candicateColor: [String] = ["#1D9BF6", "#B90E28", "#FD8208", "FF2D55", "FECF0F"]
    var appleCalendarColor: String {
        candicateColor.randomElement() ?? "#1D9BF6"
    }
    
    fileprivate var timeZone = ICSTimeZone.Asia_Shanghai
    
    var events: [ICSEvent] = []
    
    private var eventsDescription: String {
        var description = ""
        for event in events {
                description += event.toICSDescription()
        }
        return description
    }
    
    init(name: String, prodID: String = "jjachen.me") {
        self.name = name
        self.prodID = prodID
    }
    
    func append(event: ICSEvent) {
        self.events.append(event)
    }
    
    func append(events: [ICSEvent]) {
        self.events.append(contentsOf: events)
    }
    
    func toICSDescription() -> String {
        """
        BEGIN:VCALENDAR
        METHOD:PUBLISH
        VERSION:2.0
        X-WR-CALNAME:\(name)
        X-PUBLISHED-TTL:PT4H
        PRODID:-//\(prodID)
        X-APPLE-CALENDAR-COLOR:\(appleCalendarColor)
        \(timeZone.toICSDescription())
        \(eventsDescription)
        END:VCALENDAR
        
        """
    }
}

class ICSEvent {
    let uuid = UUID()
    let createdDate = Date()
    
    fileprivate var timeZone = ICSTimeZone.Asia_Shanghai
    var startDate: Date
    var endDate: Date
    
    var title: String
    var location: String?
    var note: String?
    
    var alarm: ICSEventAlarm?
    
    init(startDate: Date, endDate: Date, title: String, location: String? = nil, note: String? = nil) {
        self.startDate = startDate
        self.endDate = endDate
        self.title = title
        self.location = location
        self.note = note
    }
    
    func setAlarm(alarm: ICSEventAlarm) {
        self.alarm = alarm
    }
    
    func toICSDescription() -> String {
        """
        BEGIN:VEVENT
        TRANSP:OPAQUE
        DTEND;TZID=\(timeZone.toString()):\(ICSDateFormatter.dateFormatter.string(from: endDate))
        UID:\(uuid.uuidString)
        DTSTAMP:\(ICSDateFormatter.dateFormatter.string(from: createdDate))Z
        LOCATION:\((location != nil) ? location! : "")
        DESCRIPTION:\((note != nil) ? note! : "")
        SEQUENCE:0
        X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
        SUMMARY:\(title)
        LAST-MODIFIED:\(ICSDateFormatter.dateFormatter.string(from: createdDate))Z
        CREATED:\(ICSDateFormatter.dateFormatter.string(from: createdDate))Z
        DTSTART;TZID=\(timeZone.toString()):\(ICSDateFormatter.dateFormatter.string(from: startDate))
        \((alarm != nil) ? alarm!.toICSDescription() : "")
        END:VEVENT
        
        """
    }
}

enum ICSEventAlarmTrigger {
    case day(Int)
    case hour(Int)
    case min(Int)
    
    func toString() -> String {
        switch self {
        case .day(let num):
            return "\(num < 0 ? "-" : "")P\(abs(num))D"
        case .hour(let num):
            return "\(num < 0 ? "-" : "")PT\(abs(num))H"
        case .min(let num):
            return "\(num < 0 ? "-" : "")PT\(abs(num))M"
        }
    }
}

enum ICSEventAlarmAction {
    case display
    case audio
    
    func toString() -> String {
        switch self {
        case .display:
            return "DISPLAY"
        case .audio:
            return "AUDIO"
        }
    }
}

class ICSEventAlarm {
    let trigger: ICSEventAlarmTrigger
    let triggerAction: ICSEventAlarmAction
    
    init(trigger: ICSEventAlarmTrigger, action: ICSEventAlarmAction = .display) {
        self.trigger = trigger
        self.triggerAction = action
    }
    
    let uuid = UUID()
    
    var description = "日程提醒"
    
    func toICSDescription() -> String {
        """
        BEGIN:VALARM
        X-WR-ALARMUID:\(uuid.uuidString)
        UID:\(uuid.uuidString)
        TRIGGER:\(trigger.toString())
        DESCRIPTION:\(description)
        \(triggerAction == .audio ? "ATTACH;VALUE=URI:Chord" : "")
        ACTION:\(triggerAction)
        END:VALARM
        
        """
    }
}
