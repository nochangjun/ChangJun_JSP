<%@page import="project.InquiryMgr"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.AdminDashboardMgr" %>
<%@ page import="project.MemberBean, project.ReportBean, project.RestaurantBean, project.InquiryBean" %>
<%
    request.setCharacterEncoding("UTF-8");

    AdminDashboardMgr mgr = new AdminDashboardMgr();
    InquiryMgr Imgr = new InquiryMgr();
    int userCount = mgr.getUserCount();
    int reportCount = mgr.getReportCount(); // 대기 중 신고만
    int storeCount = mgr.getPendingStoreCount(); // 승인 대기 가게만
    int inquiryCount = mgr.getPendingInquiryCount(); // 대기중 문의만

    MemberBean latestUser = mgr.getLatestUser();
    ReportBean latestReport = mgr.getLatestPendingReport();
    RestaurantBean latestStore = mgr.getLatestRestaurant();
    InquiryBean latestInquiry = mgr.getLatestInquiry();
    
    int totalInquiryCount = Imgr.getFilteredInquiryCount("대기중", null, null); // 대기중 상태 전체 카운트
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>관리자 대시보드</title>
<link rel="stylesheet" type="text/css" href="../css/admin_Main.css">
<script>
	function navigateTo(page, id) {
		window.location.href = page + "?id=" + id;
	}
</script>
</head>
<body>
	<!-- 사이드바 및 헤더 인클루드 -->
	<%@ include file="../admin_Header.jsp" %>

	<div class="main-content">
		<div class="tasks">
			<h2>오늘의 할 일</h2>
			<hr class="divider">
			<ul>
				<li>사용자 관리 <span class="yellow-text"><%= userCount %></span></li>
				<li>신고 관리 <span class="yellow-text"><%= reportCount %></span></li>
				<li>가게 승인/관리 <span class="yellow-text"><%= storeCount %></span></li>
				<li>문의 관리 <span class="yellow-text"><%= inquiryCount %></span></li>
			</ul>
		</div>
		<div class="dashboard">
			<div class="card">
				<div class="card-header">
					<h3><button onclick="location.href='admin_UM.jsp'">사용자 관리 &gt;</button></h3>
				</div>
				<table>
					<tr><th>이름</th><th>아이디</th><th>이메일</th><th>가입일</th></tr>
					<% if (latestUser != null) { %>
					<tr onclick="navigateTo('admin_UM.jsp', '<%= latestUser.getMember_id() %>')">
					    <td><%= latestUser.getMember_name() %></td>
					    <td><%= latestUser.getMember_id() %></td>
					    <td><%= latestUser.getMember_email() %></td>
					    <td><%= latestUser.getMember_create_at() %></td>
					</tr>
					<% } else { %>
					<tr>
					    <td colspan="4" style="text-align: center;">최근 가입한 회원이 없습니다.</td>
					</tr>
					<% } %>
				</table>
			</div>
			<div class="card">
				<div class="card-header">
					<h3><button onclick="location.href='admin_Report.jsp'">신고 관리 &gt;</button></h3>
				</div>
				<table>
				    <tr><th>이름</th><th>아이디</th><th>신고일</th><th>사유</th></tr>
				    <% if (latestReport != null) { %>
				    <tr onclick="window.open('/myapp/admin/ReportDetailServlet?report_id=<%= latestReport.getReport_id() %>', 'reportDetail', 'width=650,height=700,resizable=no,scrollbars=yes')">
				        <td><%= latestReport.getMember_name() %></td>
				        <td><%= latestReport.getReported_member_id() %></td>
				        <td><%= latestReport.getReport_created_at() %></td>
				        <td><%= latestReport.getReport_reason() %></td>
				    </tr>
				    <% } else { %>
				    <tr>
				        <td colspan="4" style="text-align: center;">최근 대기중인 신고가 없습니다.</td>
				    </tr>
				    <% } %>
				</table>
			</div>
			<div class="card">
				<div class="card-header">
					<h3><button onclick="location.href='admin_Rst_Approval.jsp'">가게 관리 &gt;</button></h3>
				</div>
				<table>
					<tr><th>가게명</th><th>지역</th><th>등록일</th></tr>
					<% if (latestStore != null) { %>
					<tr onclick="location.href='admin_Rst_List_Detail.jsp?rst_id=<%= latestStore.getRst_id() %>'">
					    <td><%= latestStore.getRst_name() %></td>
					    <td><%= latestStore.getRegionLabel() %></td>
					    <td><%= latestStore.getCreated_at() %></td>
					</tr>
					<% } else { %>
					<tr>
					    <td colspan="3" style="text-align: center;">최근 등록된 가게가 없습니다.</td>
					</tr>
					<% } %>
				</table>
			</div>
			<div class="card">
				<div class="card-header">
					<h3><button onclick="location.href='admin_Inquiry.jsp'">문의 관리 &gt;</button></h3>
				</div>
			<table>
			    <tr><th>번호</th><th>문의 유형</th><th>작성자</th><th>작성일</th></tr>
			    <% if (latestInquiry != null) { %>
			    <tr onclick="window.open('/myapp/admin/InquiryDetailServlet?inq_id=<%= latestInquiry.getInq_id() %>', 'inquiryDetail', 'width=650,height=700,resizable=no,scrollbars=yes')">
			        <td><%= totalInquiryCount %></td>
			        <td><%= latestInquiry.getInq_type() %></td>
			        <td><%= latestInquiry.getMember_name() %></td>
			        <td><%= latestInquiry.getInq_create_at() %></td>
			    </tr>
			    <% } else { %>
			    <tr>
			        <td colspan="4" style="text-align: center;">최근 대기중인 문의가 없습니다.</td>
			    </tr>
			    <% } %>
			</table>
			</div>
		</div>
	</div>
</body>
</html>