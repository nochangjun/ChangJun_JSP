<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.NoticeBean, project.NoticeMgr, project.NoticeMgr, java.util.List" %>
<%
    String idKey = (String) session.getAttribute("idKey");
    String loginType = (String) session.getAttribute("loginType");
    boolean isLoggedIn = (idKey != null);

    NoticeMgr mgr = new NoticeMgr();
    
	// 삭제 처리
    String deleteId = request.getParameter("delete_id");
    if (deleteId != null) {
        try {
            int noticeId = Integer.parseInt(deleteId);
            mgr.deleteNotice(noticeId);
            response.setStatus(200);
            return; // 응답 종료
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            return;
        }
    }
    
	// 알림 목록 조회
    List<NoticeBean> noticeList = mgr.getNoticesByMemberId(idKey);
    boolean hasNewNotice = false;
    if (idKey != null) {
        hasNewNotice = mgr.hasNewNotice(idKey); // ✅ is_read = 0 여부로 체크
    }
%>

<script>
    const contextPath = "<%= request.getContextPath() %>";
    window.hasNewNotice = <%= hasNewNotice %> && !localStorage.getItem("notified");
</script>

<!-- 알림 팝업 자바스크립트 -->
<script src="${pageContext.request.contextPath}/project/js/notice_Popup.js"></script>

<!-- 알림 팝업 스타일 -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/project/css/notice_Popup.css">

<!-- 알림 팝업 오버레이 (초기 상태는 숨김) -->
<div id="noticeOverlay"></div>

<!-- 알림 팝업 컨테이너 (초기 상태는 숨김) -->
<div id="noticePopup">
    <div class="notice-header">
        <h2>
        	<img src="${pageContext.request.contextPath}/project/img/알림2.png" alt="알림 아이콘" class="notice-title-icon">
        	알림
        </h2>
        <button onclick="closeNoticePopup()">닫기</button>
    </div>
    
    <% if (isLoggedIn) { %>
		    <div class="notice-filter">
		        <button class="filter-btn active" onclick="filterNotices('전체')">전체</button>
		        <button class="filter-btn" onclick="filterNotices('문의')">문의</button>
		        <button class="filter-btn" onclick="filterNotices('게시판')">게시판</button>
		        <button class="filter-btn" onclick="filterNotices('가게등록')">가게등록</button>
		        <button class="filter-btn" onclick="filterNotices('신고')">신고</button>
		    </div>
    <% } %>
    
	<div class="notice-list">
	    <% if (!isLoggedIn) { %>
			    <div class="notice-login-required">
			        <p>
			            <strong>로그인이 필요한 기능입니다.</strong><br>
			            로그인 후 알림을 확인할 수 있습니다.
			        </p>
			    </div>
		<% } else { %>
					<% if (noticeList == null || noticeList.isEmpty()) { %>
						<div id="noNoticeMessage" style="text-align: center; color: #888; margin-top: 20px;">
				            알림이 없습니다.
				        </div>
			        <% } else { %>
					<% for (NoticeBean notice : noticeList) {
						       String category = 
						           (notice.getInq_id() != 0) ? "문의" :
						           (notice.getComment_id() != 0) ? "게시판" :
						           ("승인".equals(notice.getStatus_info()) || "거절".equals(notice.getStatus_info())) ? "가게등록" :
						           (notice.getReport_id() != 0) ? "신고" : "기타";
					%>
							<div class="notice-item" data-id="<%= notice.getNotice_id() %>" data-category="<%= category %>">
							    <div class="notice-item-header">
							        <img src="${pageContext.request.contextPath}/project/img/구머링.png" alt="알림 아이콘" class="notice-icon">
							        <span class="notice-source">관리자</span>
							    </div>
							    <% if (notice.getInq_id() != 0) { %>
		   								<a href="${pageContext.request.contextPath}/project/support/support_Inquiry_Detail.jsp?id=<%= notice.getInq_id() %>" class="notice-link">
										    <p class="notice-content">
										        회원님의 <strong>문의글 '<%= notice.getInq_title() %>'</strong>에 답변이 등록되었습니다.
										    </p>
										</a>
								<% } else if (notice.getComment_id() != 0) { %>
								    	<% if (notice.isReply()) { %>
									        <!-- 대댓글 알림 -->
									        <a href="${pageContext.request.contextPath}/project/support/support_Board_Detail.jsp?id=<%= notice.getBoard_id() %>" class="notice-link">
									            <p class="notice-content">
									                회원님의 <strong>댓글</strong>에 답글이 등록되었습니다.
									            </p>
									        </a>
									    <% } else { %>
									        <!-- 게시글 댓글 알림 -->
									        <a href="${pageContext.request.contextPath}/project/support/support_Board_Detail.jsp?id=<%= notice.getBoard_id() %>" class="notice-link">
									            <p class="notice-content">
									                회원님의 <strong>게시글 '<%= notice.getBoard_title() %>'</strong>에 댓글이 등록되었습니다.
									            </p>
									        </a>
									    <% } %>
								<% } else if ("승인".equals(notice.getStatus_info()) || "거절".equals(notice.getStatus_info())) { %>
								    	<% if ("승인".equals(notice.getStatus_info())) { %>
									        <p class="notice-content">
									            가게 등록 요청이 <strong>승인</strong>되었습니다.
									        </p>
									    <% } else { %>
									        <p class="notice-content">
									            가게 등록 요청이 <strong>거절</strong>되었습니다.
									        </p>
									    <% } %>
								<% } else if (notice.getReport_id() != 0) { %>
											<%
									            String reportStatus = notice.getReport_status();
									            String type = notice.getReport_type();
									            String target = "콘텐츠";
									            if ("board".equals(type)) target = "게시글";
									            else if ("comment".equals(type)) target = "댓글";
									            else if ("review".equals(type)) target = "리뷰";
											%>
											<p class="notice-content">
												<%
										         	// 신고 처리 완료 메시지 수정
												    if ("완료".equals(reportStatus)) {
												        if (idKey.equals(notice.getReporter_id())) {
												            // 신고한 사용자에게
												        %>
												            회원님이 신고한 <strong><%=target%></strong>의 신고 처리가 완료되었습니다.
												        <%
												        } else if (idKey.equals(notice.getReported_member_id())) {
												            // 신고당한 사용자에게
												        %>
												            회원님의 <strong><%=target%></strong>이(가) 신고 처리되어 3일간 제제되었습니다.
												        <%
												        }
												    } else if ("대기".equals(reportStatus) && idKey.equals(notice.getReporter_id())) {
										        %>
										                회원님이 신고한 <strong><%= target %></strong>이(가) 접수되었습니다.
										        <%
										            } else {
										        %>
										        		새로운 신고 알림입니다.
										        <%
										            }
										        %>
										    </p>
								<% } else { %>
									    <p class="notice-content">새로운 알림이 도착했습니다.</p>
								<% } %>
							    <button class="notice-close" onclick="removeNotice(this)">X</button>
							</div>
						<% } %>
				<% } %>
		<% } %>
	</div>
</div>