//
//  URLConstants.swift
//  Whiteboard
//
//  Created by JJAYCHEN on 2020/5/28.
//

// MARK: - ECNU Service

// 发现直接用大夏学堂登录可以同时登录数据库，反之不行。
let ECNU_PORTAL_URL = "https://portal1.ecnu.edu.cn/cas/login?service=https://elearning.ecnu.edu.cn/webapps/cas-hdsfdx-BBLEARN/index.jsp"
let ECNU_CAPTCHA_URL = "https://portal1.ecnu.edu.cn/cas/code"
let ECNU_IDS_URL = "http://applicationnewjw.ecnu.edu.cn/eams/courseTableForStd!index.action"
let ECNU_COURSE_TABLE_URL = "http://applicationnewjw.ecnu.edu.cn/eams/courseTableForStd!courseTable.action"
let ECNU_COURSE_QUERY_URL = "http://applicationnewjw.ecnu.edu.cn/eams/publicSearch!search.action"
let ECNU_PLAN_PANEL_URL = "http://applicationnewjw.ecnu.edu.cn/eams/myPlanCompl.action"
//let ECNU_ELEARNING_DEADLINE_URL = "https://elearning.ecnu.edu.cn/webapps/calendar/calendarData/selectedCalendarEvents"
// selectedCalendarEvents 会受用户在 elearning 上的选择影响
let ECNU_ELEARNING_DEADLINE_URL = "https://elearning.ecnu.edu.cn/webapps/calendar/calendarData/allCourseEvents"
let ECNU_ELEARNING_DEADLINE_CALENDAR_FEED_URL = "https://elearning.ecnu.edu.cn/webapps/calendar/calendarFeed/url"

// MARK: - Ecard Service

let ECARD_PORTAL_URL = "http://ecard.ecnu.edu.cn/weblogin"
let ECARD_CAPTCHA_URL = "http://ecard.ecnu.edu.cn/util/rand"
let ECARD_USER_INFO_URL = "http://ecard.ecnu.edu.cn/user/getCustomerData"
let ECARD_BALANCE_QUERY_URL = "http://ecard.ecnu.edu.cn/user/getMainAndSubCustomers"

// MARK: - Libecnu Service
let LIBECNU_LOGIN_URL = "https://libecnu.lib.ecnu.edu.cn/patroninfo*chx~S0"
