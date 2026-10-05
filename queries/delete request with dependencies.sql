delete from Requests where IssuerId = (select id from AbpUsers where Email = 'o.emam@excp.sa')

delete from AttendanceRecords where LeaveRequestId  In (select id from Requests where IssuerId = (select id from AbpUsers where Email = 'o.emam@excp.sa'))

delete from RequestReceivers where RequestId In (select id from Requests where IssuerId = (select id from AbpUsers where Email = 'o.emam@excp.sa'))


delete from Notifications where RequestId In (select id from Requests where IssuerId = (select id from AbpUsers where Email = 'o.emam@excp.sa'))

delete from RequestHistories where RequestId In (select id from Requests where IssuerId = (select id from AbpUsers where Email = 'o.emam@excp.sa'))