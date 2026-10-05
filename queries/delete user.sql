update AbpUsers set LeaderId = NULL Where LeaderId = 'BE2A52BE-92E3-44C9-9025-D68FA6FC0B13'
delete from RequestReceivers where ReceiverId = 'BE2A52BE-92E3-44C9-9025-D68FA6FC0B13'
delete from RequestReceivers where RequestId in (select id from Requests where IssuerId = 'BE2A52BE-92E3-44C9-9025-D68FA6FC0B13')
delete from RequestHistories where RequestId in (select id from Requests where IssuerId = 'BE2A52BE-92E3-44C9-9025-D68FA6FC0B13')
delete from RequestHistories where ActionById = 'BE2A52BE-92E3-44C9-9025-D68FA6FC0B13'
delete from Requests where overTimeId IN (select Id from AttendanceOverTime where LeaderId = 'BE2A52BE-92E3-44C9-9025-D68FA6FC0B13')
delete from Requests where IssuerId = 'BE2A52BE-92E3-44C9-9025-D68FA6FC0B13'
delete from RequestReceivers where RequestId in (select RequestId from Requests where OverTimeId in (select id from AttendanceOverTime where LeaderId = 'BE2A52BE-92E3-44C9-9025-D68FA6FC0B13'))
delete from Requests where OverTimeId in (select id from AttendanceOverTime where LeaderId = 'BE2A52BE-92E3-44C9-9025-D68FA6FC0B13')
delete from AttendanceOverTime where LeaderId = 'BE2A52BE-92E3-44C9-9025-D68FA6FC0B13'
delete from Notifications where ReceiverId = 'BE2A52BE-92E3-44C9-9025-D68FA6FC0B13'
delete from AttendanceBreak where  AttendanceRecordId in (select id from AttendanceRecords where UserId = 'BE2A52BE-92E3-44C9-9025-D68FA6FC0B13')
delete from AttendanceRecords where UserId = 'BE2A52BE-92E3-44C9-9025-D68FA6FC0B13'
delete from AbpUsers where Id = 'BE2A52BE-92E3-44C9-9025-D68FA6FC0B13'

select id from AbpUsers where email = 'mahmoud@gmail.com'