<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.ReportBean, project.ReportMgr" %>
<%
    request.setCharacterEncoding("UTF-8");
	
	
    // 관리자 세션 체크
    String adminId = (String) session.getAttribute("admin_id");
    if (adminId == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }
    
    // URL 파라미터로 신고 ID 받기
    String reportIdStr = request.getParameter("report_id");
    if (reportIdStr == null) {
        out.println("신고 ID가 전달되지 않았습니다.");
        return;
    }

    int reportId = 0;
    try {
        reportId = Integer.parseInt(reportIdStr);
    } catch(Exception e) {
        out.println("잘못된 신고 ID입니다.");
        return;
    }

    // ReportMgr을 통해 신고 상세 정보 조회
    ReportMgr mgr = new ReportMgr();
    ReportBean report = mgr.getReportDetail(reportId);
    if (report == null) {
        out.println("해당 신고 내역을 찾을 수 없습니다.");
        return;
    }
    
    // 신고 대상의 내용을 가져옴 (게시글, 댓글, 리뷰 등)
    String reportedContent = mgr.getReportedContent(report.getReport_type(), report.getReport_target_id());
    
    // 신고 유형 변환 (board -> 게시글, comment -> 댓글, review -> 리뷰)
    String displayType = "";
    if ("board".equals(report.getReport_type())) displayType = "게시글";
    else if ("comment".equals(report.getReport_type())) displayType = "댓글";
    else if ("review".equals(report.getReport_type())) displayType = "리뷰";
    else displayType = report.getReport_type();
    
    // 상태 표시를 위한 CSS 클래스 (문의 상세보기 페이지와 유사하게 처리)
    String status = report.getReport_status();
    String statusClass = "";
    if ("대기".equals(status) || "대기중".equals(status)) {
        statusClass = "status-pending";
    } else if ("완료".equals(status)) {
        statusClass = "status-completed";
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>신고 상세 정보</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/project/css/admin_Report_Detail.css">
<script>
    function closeModal() {
        window.close(); // 팝업 창 닫기
    }
    
</script>
</head>
<body>
	<div class="modal-overlay" id="reportModal">
	    <div class="modal-content">
	        <div class="modal-close" onclick="closeModal()">✕</div>
	        <h2>신고 상세 정보</h2>
	        
	        <div class="info-box">
	            <span class="label">신고 번호:</span>
	            <%= report.getReport_id() %>
	        </div>
	        <div class="info-box">
	            <span class="label">신고 유형:</span>
	            <%= displayType %>
	        </div>
	        <div class="info-box">
	            <span class="label">신고자:</span>
	            <%= report.getReporter_id() %>
	        </div>
	        <div class="info-box">
	            <span class="label">신고 대상:</span>
	            <%= report.getReported_member_id() %>
	            <%= (report.getMember_name() != null && !report.getMember_name().trim().isEmpty()) ? "(" + report.getMember_name() + ")" : "" %>
	        </div>
	        <div class="info-box">
	            <span class="label">작성일:</span>
	            <%= report.getReport_created_at() %>
	        </div>
	        <div class="info-box">
	            <span class="label">상태:</span>
	            <span class="status-label <%= statusClass %>"><%= status %></span>
	        </div>
	        
	        <h4>신고 대상 내용</h4>
	        <div class="info-box">
	            <textarea readonly style="width:100%; height:120px;"><%= reportedContent %></textarea>
	        </div>
	        
	        <h4>신고 내용</h4>
	        <div class="info-box">
	            <textarea readonly style="width:100%; height:120px;"><%= report.getReport_reason() %></textarea>
	        </div>
	        
	        <!-- 신고 처리(관리자 답변) 폼: 필요에 따라 신고 처리를 위한 메모 입력 후 처리할 수 있음 -->
	        <h4>신고 처리</h4>
	        <% if ("완료".equals(status)) { %>
	            <!-- 처리 완료된 신고에 대해서는 처리 완료 버튼을 숨깁니다. -->
	            <p>이미 신고가 처리되었습니다.</p>
	        <% } else { %>
	            <form action="<%= request.getContextPath() %>/project/admin/reportProcess.do" method="post">
	                <input type="hidden" name="report_id" value="<%= report.getReport_id() %>" />
	                <textarea name="process_note" placeholder="처리 내용을 작성하세요..." style="width:100%; height:80px;"></textarea>
	                <div class="btn-group" style="margin-top:10px;">
	                    <button type="submit" name="action" value="process">처리 완료</button>
	            </div>
	        </form>
	        <% } %>
	        <script>
			    function closeForm() {
			        window.opener.location.reload(); // 부모 창 새로 고침
			        window.close(); // 현재 팝업 창 닫기
			    }
			</script>
	    </div>
	</div>
</body>
</html>
