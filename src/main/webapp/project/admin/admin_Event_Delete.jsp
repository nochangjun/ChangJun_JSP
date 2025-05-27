<!-- admin_Event_Delete.jsp-->
<%@page import="project.EvtParticipantsBean"%>
<%@page import="project.EvtParticipantsMgr"%>
<%@page import="project.EventBean"%>
<%@page import="project.EventMgr"%>
<%@page import="java.util.Vector"%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
	request.setCharacterEncoding("UTF-8");
	String result = request.getParameter("result"); // 등록 결과(success/fail)

	// 페이지네이션 파라미터 처리
	int eventPageSize = 3;
	int winnerPageSize = 3;
	int eventPageNum = request.getParameter("eventPage") != null ? Integer.parseInt(request.getParameter("eventPage")) : 1;
	int winnerPageNum = request.getParameter("winnerPage") != null ? Integer.parseInt(request.getParameter("winnerPage")) : 1;
	int eventStartRow = (eventPageNum - 1) * eventPageSize;
	int winnerStartRow = (winnerPageNum - 1) * winnerPageSize;

	EventMgr eventMgr = new EventMgr();
	EvtParticipantsMgr winnerMgr = new EvtParticipantsMgr();

	Vector<EventBean> allEvents = eventMgr.getVisibleEvents();
	Vector<EvtParticipantsBean> allWinners = winnerMgr.getAllWinners();

	int eventTotalCount = allEvents.size();
	int winnerTotalCount = allWinners.size();
	int eventTotalPage = (int) Math.ceil((double) eventTotalCount / eventPageSize);
	int winnerTotalPage = (int) Math.ceil((double) winnerTotalCount / winnerPageSize);

	int eventPageBlock = 5;
	int eventStartPage = ((eventPageNum - 1) / eventPageBlock) * eventPageBlock + 1;
	int eventEndPage = Math.min(eventStartPage + eventPageBlock - 1, eventTotalPage);

	int winnerPageBlock = 5;
	int winnerStartPage = ((winnerPageNum - 1) / winnerPageBlock) * winnerPageBlock + 1;
	int winnerEndPage = Math.min(winnerStartPage + winnerPageBlock - 1, winnerTotalPage);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>이벤트 삭제 - YUMMY JEJU</title>
	<link rel="stylesheet" href="../css/admin_Event_Participants.css">
	<script>
		function confirmDelete(form) {
			if (confirm('정말 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.')) {
				form.submit();
			}
			return false;
		}
	</script>
</head>
<body>
	<!-- 사이드바 및 헤더 인클루드 -->
	<%@ include file="../admin_Header.jsp" %>

	<!-- 메인 컨텐츠 영역 -->
	<div class="main-content">
		<!-- 이벤트 삭제 섹션 - 향상된 UI -->
		<section class="event-section">
			<h2>이벤트 등록/관리</h2>
			
			<!-- 탭 메뉴 - 기존 위치 유지 -->
			<div class="tabs">
				<a href="admin_Event_Register.jsp" class="tab-btn">이벤트 등록</a>
				<a href="admin_Event_Participants.jsp" class="tab-btn">당첨자 등록</a>
				<a href="admin_Event_Delete.jsp" class="tab-btn active">삭제</a>
			</div>

			<!-- 결과 메시지 표시 -->
			<% if ("success".equals(result)) { %>
				<p style="color: green;">✅ 삭제가 완료되었습니다.</p>
			<% } else if ("fail".equals(result)) { %>
				<p style="color: red;">❌ 삭제 처리 중 오류가 발생했습니다.</p>
			<% } %>

			<!-- 이벤트 목록 조회 - 향상된 UI -->
			<h3>이벤트 목록</h3>
			<div class="table-container">
				<table class="data-table">
					<thead>
						<tr>
							<th>제목</th>
							<th>기간</th>
							<th>관리</th>
						</tr>
					</thead>
					<tbody>
					<% if (eventTotalCount == 0) { %>
						<tr class="empty-row">
							<td colspan="3">등록된 이벤트가 없습니다.</td>
						</tr>
					<% } else {
						for (int i = eventStartRow; i < Math.min(eventStartRow + eventPageSize, eventTotalCount); i++) {
							EventBean event = allEvents.get(i);
					%>
						<tr>
							<td><%= event.getTitle() %></td>
							<td><%= event.getStartDate() %> ~ <%= event.getEndDate() %></td>
							<td>
								<form action="<%= request.getContextPath() %>/project/admin/deleteEvent" method="post" style="display:inline;" onsubmit="return confirmDelete(this)">
									<input type="hidden" name="id" value="<%= event.getEventId() %>">
									<input type="hidden" name="type" value="event">
									<button type="submit" class="delete-btn">🗑 삭제</button>
								</form>
							</td>
						</tr>
					<% 
						}
					} 
					%>
					</tbody>
				</table>
			</div>
			
			<!-- 이벤트 페이지네이션 - 향상된 UI -->
			<% if (eventTotalPage > 0) { %>
			<div class="pagination">
				<% for (int i = eventStartPage; i <= eventEndPage; i++) { %>
					<% if (i == eventPageNum) { %>
						<strong><%= i %></strong>
					<% } else { %>
						<a href="admin_Event_Delete.jsp?eventPage=<%= i %>&winnerPage=<%= winnerPageNum %>"><%= i %></a>
					<% } %>
				<% } %>
			</div>
			<% } %>
			
			<!-- 당첨자 발표 목록 조회 - 향상된 UI -->
			<h3>당첨자 발표 목록</h3>
			<div class="table-container">
				<table class="data-table">
					<thead>
						<tr>
							<th>제목</th>
							<th>등록일</th>
							<th>관리</th>
						</tr>
					</thead>
					<tbody>
					<% if (winnerTotalCount == 0) { %>
						<tr class="empty-row">
							<td colspan="3">등록된 당첨자 발표가 없습니다.</td>
						</tr>
					<% } else {
						for (int i = winnerStartRow; i < Math.min(winnerStartRow + winnerPageSize, winnerTotalCount); i++) {
							EvtParticipantsBean win = allWinners.get(i);
					%>
						<tr>
							<td><%= win.getEvt_title() %></td>
							<td><%= win.getEvt_created_at().substring(0, 10) %></td>
							<td>
								<form action="<%= request.getContextPath() %>/project/admin/deleteEvent" method="post" style="display:inline;" onsubmit="return confirmDelete(this)">
									<input type="hidden" name="id" value="<%= win.getEvt_id() %>">
									<input type="hidden" name="type" value="winner">
									<button type="submit" class="delete-btn">🗑 삭제</button>
								</form>
							</td>
						</tr>
					<% 
						}
					} 
					%>
					</tbody>
				</table>
			</div>
			
			<!-- 당첨자 페이지네이션 - 향상된 UI -->
			<% if (winnerTotalPage > 0) { %>
			<div class="pagination">
				<% if (winnerPageNum > 1) { %>
					<a href="admin_Event_Delete.jsp?eventPage=<%= eventPageNum %>&winnerPage=1" title="처음으로">&laquo;</a>
				<% } %>
				
				<% if (winnerStartPage > 1) { %>
					<a href="admin_Event_Delete.jsp?eventPage=<%= eventPageNum %>&winnerPage=<%= winnerStartPage - 1 %>" title="이전">&lsaquo;</a>
				<% } %>
				
				<% for (int i = winnerStartPage; i <= winnerEndPage; i++) { %>
					<% if (i == winnerPageNum) { %>
						<strong><%= i %></strong>
					<% } else { %>
						<a href="admin_Event_Delete.jsp?eventPage=<%= eventPageNum %>&winnerPage=<%= i %>"><%= i %></a>
					<% } %>
				<% } %>
				
				<% if (winnerEndPage < winnerTotalPage) { %>
					<a href="admin_Event_Delete.jsp?eventPage=<%= eventPageNum %>&winnerPage=<%= winnerEndPage + 1 %>" title="다음">&rsaquo;</a>
				<% } %>
				
				<% if (winnerPageNum < winnerTotalPage) { %>
					<a href="admin_Event_Delete.jsp?eventPage=<%= eventPageNum %>&winnerPage=<%= winnerTotalPage %>" title="마지막으로">&raquo;</a>
				<% } %>
			</div>
			<% } %>
		</section>
	</div>
</body>
</html>