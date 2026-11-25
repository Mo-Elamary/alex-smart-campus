from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Image, KeepTogether
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import cm
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase import pdfmetrics
from pathlib import Path

root = Path(__file__).resolve().parent
out = root / 'Alex_Smart_Campus_Project_Report.pdf'
pdfmetrics.registerFont(TTFont('Arial', r'C:\Windows\Fonts\arial.ttf'))
pdfmetrics.registerFont(TTFont('ArialBold', r'C:\Windows\Fonts\arialbd.ttf'))
styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name='CoverTitleX',fontName='ArialBold',fontSize=29,leading=36,textColor=colors.HexColor('#102D31'),spaceAfter=14))
styles.add(ParagraphStyle(name='CoverSubX',fontName='Arial',fontSize=13,leading=20,textColor=colors.HexColor('#426166')))
styles.add(ParagraphStyle(name='HeadingX',fontName='ArialBold',fontSize=16,leading=22,textColor=colors.HexColor('#13292B'),spaceAfter=9))
styles.add(ParagraphStyle(name='OwnerX',fontName='ArialBold',fontSize=10,leading=14,textColor=colors.HexColor('#086C72'),spaceAfter=12))
styles.add(ParagraphStyle(name='BodyX',fontName='Arial',fontSize=10.4,leading=15,spaceAfter=7,textColor=colors.HexColor('#243437')))
styles.add(ParagraphStyle(name='CaptionX',fontName='Arial',fontSize=9,leading=12,alignment=TA_CENTER,textColor=colors.HexColor('#50666A'),spaceBefore=4,spaceAfter=8))
styles.add(ParagraphStyle(name='CellX',fontName='Arial',fontSize=9.2,leading=13))
styles.add(ParagraphStyle(name='CellWhiteX',fontName='ArialBold',fontSize=9.2,leading=13,textColor=colors.white))
styles.add(ParagraphStyle(name='LabelX',fontName='ArialBold',fontSize=10,leading=14,textColor=colors.HexColor('#143C40'),spaceBefore=3,spaceAfter=3))

def p(t,sty='BodyX'): return Paragraph(t,styles[sty])
def screen(filename, caption):
    path = root / 'assets' / 'report_screenshots' / filename
    w,h=ImageReader(str(path)).getSize()
    target_h=12.0*cm
    image=Image(str(path),width=target_h*w/h,height=target_h)
    image.hAlign='CENTER'
    return [image,p(caption,'CaptionX')]

def section(title,owner,explain,code,choice,img,caption,summary):
    story.extend([p(title + ' | ' + owner,'HeadingX'),p('Suggested presentation role','OwnerX'),p('1  Feature overview','LabelX'),p(explain),p('2  Code location and implementation','LabelX'),p(code),p('<b>Technology choice:</b> '+choice),p('3  Application screenshot','LabelX')])
    story.extend(screen(img,caption))
    story.extend([p('4  Section summary','LabelX'),p(summary),PageBreak()])

doc = SimpleDocTemplate(str(out),pagesize=A4,rightMargin=2.0*cm,leftMargin=2.0*cm,topMargin=1.65*cm,bottomMargin=1.55*cm,title='Alex Smart Campus Project Report',author='Alex Smart Campus Team')
story=[]
story += [Spacer(1,3.1*cm),p('ALEXANDRIA UNIVERSITY','OwnerX'),Spacer(1,.3*cm),p('Alex Smart Campus<br/>Project Report','CoverTitleX'),p('Mobile Computing | Final Project | Fall 2026','CoverSubX'),Spacer(1,1.1*cm),p('Faculty of Computers and Data Science<br/>Cybersecurity Department','CoverSubX'),Spacer(1,.8*cm),p('<b>Course instructor:</b> Dr Mohamed Khamis<br/><b>Teaching assistant:</b> Sara El Desouky'),Spacer(1,1.4*cm),p('A Flutter Android application combining a local class schedule, live announcements, secure accounts, personal profiles and current Alexandria weather.'),PageBreak()]
story += [p('Team and presentation roles','HeadingX'),p('The following roles are a suggested division for the project discussion. Student ID fields are intentionally left blank for completion once team membership is confirmed.'),Spacer(1,.2*cm)]
rows=[('Name','Student ID','Suggested role'),('Mohamed Elamary','','UI and navigation'),('Fahd Mohamed','','Authentication'),('Abdelrahman Hany','','Firestore profile'),('Abdallah Sameh','','Realtime announcements'),('Ezz Eldin','','Offline schedule with Hive'),('Marawan Samy','','Settings and SharedPreferences'),('Ziad Ahmed','','Weather REST API')]
t=Table([[p(v,'CellWhiteX' if i==0 else 'CellX') for v in row] for i,row in enumerate(rows)],colWidths=[5.0*cm,3.2*cm,8.3*cm],repeatRows=1,hAlign='LEFT')
t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#164B50')),('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.white,colors.HexColor('#F1F7F7')]),('GRID',(0,0),(-1,-1),.45,colors.HexColor('#D9E1E1')),('VALIGN',(0,0),(-1,-1),'MIDDLE'),('TOPPADDING',(0,0),(-1,-1),9),('BOTTOMPADDING',(0,0),(-1,-1),9)]))
story += [t,Spacer(1,.5*cm),p('Project overview','HeadingX'),p('Alex Smart Campus provides a single place for everyday student information. Firebase supports identity and cloud data, while Hive keeps timetable entries on the device. The following sections explain the feature, where to find its implementation, the corresponding screen, and its key takeaway.'),p('<b>Scope:</b> The seven-member team exception is subject to course approval. The announcement shown is demonstration data rather than an official university notice.'),PageBreak()]
section('01  Interface and navigation','Mohamed Elamary','Students move between Home, Schedule, Updates and Profile using the bottom navigation bar. Sign-in and registration appear before the main application. The interface supports light and dark themes and uses scrollable forms and content.','<b>lib/screens/home_screen.dart:</b> HomeScreen builds the navigation bar and switches between the four destinations. <b>lib/main.dart:</b> CampusApp supplies themes and chooses the signed-in or authentication screen.','Flutter provides a single Dart UI toolkit and reusable Material components.','home.png','Figure 1. Home screen and bottom navigation.','The interface groups the main student tasks into four clear destinations.')
section('02  Account authentication','Fahd Mohamed','Students register, sign in and sign out using email and password. The authentication session is restored after reopening the app, and common sign-in failures are shown as readable messages.','<b>lib/screens/auth_screen.dart:</b> AuthScreen.submit validates the form and calls Firebase Authentication. <b>lib/main.dart:</b> authStateChanges selects the appropriate screen.','Firebase Authentication supplies managed account handling and session persistence.','login.png','Figure 2. Email and password sign-in screen.','Authentication controls access and keeps the account signed in between app launches.')
section('03  User profile and Firestore','Abdelrahman Hany','Each user can view and edit a name and image URL. If the image is absent or fails to load, initials provide a fallback. The screenshot also shows the account email and profile controls.','<b>lib/screens/auth_screen.dart:</b> registration creates users/{uid} with name, email, photoUrl and createdAt. <b>lib/screens/home_screen.dart:</b> ProfilePage observes and updates the document. <b>firestore.rules:</b> access is limited to the matching UID.','Firestore stores structured profile documents and provides a stream for displaying changes.','profile.png','Figure 3. Profile with initials and edit control.','Each account has a private profile document and an optional image URL.')
section('04  Live campus announcements','Abdallah Sameh','The Updates screen shows announcement titles, bodies and timestamps. A subscription updates the list when an announcement changes in Firebase; announcements can be maintained through the console.','<b>lib/screens/home_screen.dart:</b> AnnouncementsPage listens to announcements with onValue and sorts by timestamp. <b>database.rules.json:</b> authenticated users may read; client writes are disabled.','Realtime Database provides a stream suited to live announcement updates.','updates.png','Figure 4. Demonstration announcement in the Updates screen.','Announcements are delivered through a live database listener without a refresh button.')
section('05  Offline schedule using Hive','Ezz Eldin','Students add, edit and delete entries containing course, day, time and room. The schedule is saved on the device and works without internet for a user who has already signed in.','<b>lib/main.dart:</b> Hive is initialized and the schedules box is opened. <b>lib/screens/home_screen.dart:</b> SchedulePage writes, edits and removes entries and observes the box.','Hive provides local persistence for structured timetable entries without a network connection.','schedule.png','Figure 5. Locally stored class schedule.','A device-local timetable remains available in airplane mode; it does not sync across devices.')
section('06  Persistent theme setting','Marawan Samy','The Profile screen includes a dark mode switch. The selected setting is kept on the device and restored when the application starts again.','<b>lib/main.dart:</b> SharedPreferences reads darkMode at startup and stores changes. <b>lib/screens/home_screen.dart:</b> ProfilePage passes switch changes back to the application.','SharedPreferences is a straightforward choice for a small key-value preference.','profile.png','Figure 6. Dark mode switch in Profile.','The app remembers the selected appearance across restarts on the same device.')
section('07  Weather from a REST API','Ziad Ahmed','The Home screen displays current Alexandria temperature and wind speed. A loading indicator appears during the request; a failure message and retry action are shown if it fails.','<b>lib/screens/home_screen.dart:</b> fetchWeather sends an HTTP request, Weather.fromJson parses the response, and Dashboard displays loading, success and error states.','Open-Meteo supplies weather by geographic coordinates; the http package handles the REST request.','home.png','Figure 7. Current weather information on Home.','Live data is parsed into a Dart model and presented with loading and error handling.')
story += [p('Testing and discussion','HeadingX'),p('The Android application was built as a debug APK. Static analysis and automated checks for weather parsing and schedule dialog interactions passed. The team reported successful schedule and profile editing on a phone after the dialog fix, as well as an airplane-mode schedule check. The Updates screenshot shows the demonstration announcement on the device.'),p('Suggested live demonstration','LabelX'),p('1. Sign in, navigate between the main screens and edit the profile.<br/>2. Show the Updates screen, then add, change or remove an announcement in the Firebase console to demonstrate a live update.<br/>3. While already signed in, enable airplane mode and add, edit and delete schedule entries; reopen the app and inspect the timetable.<br/>4. Restore connectivity, show weather and change the theme; reopen the app to demonstrate preference persistence.'),p('Implementation boundaries','LabelX'),p('The timetable is stored on each device, not synchronized between devices. First-time authentication and live cloud or weather data require internet. The welcome announcement is test content. Firebase security rules must remain deployed for the project.'),p('Conclusion','LabelX'),p('The application integrates Flutter navigation, Firebase Authentication, Firestore profiles, Realtime Database announcements, Hive and SharedPreferences local persistence, and a REST API in a single student-facing Android application.')]
def footer(canvas,doc):
    canvas.saveState(); canvas.setStrokeColor(colors.HexColor('#DBE7E6')); canvas.line(2*cm,1.15*cm,A4[0]-2*cm,1.15*cm); canvas.setFont('Arial',8); canvas.setFillColor(colors.HexColor('#63787A')); canvas.drawString(2*cm,.72*cm,'ALEX SMART CAMPUS  |  MOBILE COMPUTING'); canvas.drawRightString(A4[0]-2*cm,.72*cm,str(doc.page)); canvas.restoreState()
doc.build(story,onFirstPage=footer,onLaterPages=footer)
print(out)


