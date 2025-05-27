<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.*" %>
<jsp:useBean id="mgr" class="project.InquiryMgr"/>
<%
	// 문의글 ID 받기
	int inquiryId = 0;
	try {
		inquiryId = Integer.parseInt(request.getParameter("id"));
	} catch (Exception e) {
		response.sendRedirect("support_Inquiry.jsp");
		return;
	}
	
	// 세션에서 로그인한 사용자 ID 가져오기 (세션 변수명은 프로젝트에 맞게 수정 필요)
	String memberId = (String)session.getAttribute("idKey");
	String loginType = (String) session.getAttribute("loginType");
	boolean isLoggedIn = (memberId != null);
	
	// 로그인 여부 확인
    if (memberId == null || memberId.trim().equals("")) {
%>
    <script>
	    if (confirm("로그인이 필요합니다. 로그인 하시겠습니까?")) {
	        location.href = "../login/login.jsp";
	    } else {
	        history.back();
	    }
    </script>
<%
        return;
    }
	 
    InquiryBean bean = mgr.getInquiryWithMember(inquiryId);

    if (bean == null) {
        response.sendRedirect("support_Inquiry.jsp");
        return;
    }

    boolean isAdmin = "partner".equals((String)session.getAttribute("loginType")); // 관리자 조건
    boolean isOwner = memberId.equals(bean.getMember_id());

    if (!isOwner && !isAdmin) {
%>
    <script>
        alert("비공개 글입니다. 작성자만 열람할 수 있습니다.");
        history.back();
    </script>
<%
        return;
    }
	
	// 문의글 삭제 처리
	if(request.getParameter("action") != null && request.getParameter("action").equals("delete")) {
		mgr.deleteInquiry(inquiryId);
		response.sendRedirect("support_Inquiry.jsp");
		return;
	}
	
	// 현재 URL 인코딩해서 login.jsp에 넘기기 위함
    String currentURL = request.getRequestURI();
    String query = request.getQueryString();
    if (query != null) {
        currentURL += "?" + query;
    }
    String encodedURL = java.net.URLEncoder.encode(currentURL, "UTF-8");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>문의글 상세보기</title>
<link rel="stylesheet" type="text/css"
	href="../css/support_Inquiry_Detail.css">
<jsp:include page="../header.jsp"></jsp:include>
</head>
<body>
	<div class="container">
		<h2 class="title">문의글</h2>

		<div class="post-header">
			<div class="post-info">
				<div class="post-title">
					<span class="label">제목</span> 
					<span class="content"> 
						<img src="../img/lock_icon.png" alt="비공개" class="lock-icon"> <%= bean.getInq_title() %>
					</span>
				</div>
				<div class="post-meta">
					<span class="date">작성일 <%= bean.getInq_create_at().toString().substring(0, 10) %></span>
					<% if(bean.getMember_id().equals(memberId)) { %>
					<div class="dropdown">
						<button class="menu-icon">&#9776;</button>
						<div class="dropdown-content">
							<button class="delete-btn" id="deleteBtn">삭제</button>
						</div>
					</div>
					<% } %>
				</div>
			</div>
			<div class="header-divider"></div>
		</div>

		<div class="post-content"><%= bean.getInq_content() %></div>
		<div class="separator"></div>

		<% 
			InqCommentBean comment = mgr.getCommentByInquiryId(inquiryId); 
		%>
		
		<% if("완료".equals(bean.getInq_status()) && comment != null) { %>
		<div class="reply-section">
		    <h3 class="reply-title">답변</h3>
		    <div class="reply-item">
		        <div class="replier-info">
		            <div class="admin-info">
		                <span class="replier-name"><%= comment.getMember_id() %></span>
		            </div>
		            <span class="reply-date"><%= comment.getInq_comment_at().toString().substring(0, 16) %></span>
		        </div>
		        <div class="reply-content">
		            <img src="../img/구머링.png" class="admin-content-icon" alt="관리자">
		            <%= comment.getInq_content().replaceAll("\n", "<br>") %>
		        </div>
		    </div>
		</div>
		<% } %>


		<div class="button-container">
			<button type="button" onclick="location.href='support_Inquiry.jsp'"
				class="list-button">목 록</button>
		</div>
	</div>

	<jsp:include page="../footer.jsp"></jsp:include>

	<script>
		// 삼단바 메뉴 클릭 이벤트
		document
				.querySelector('.menu-icon')
				.addEventListener(
						'click',
						function() {
							var dropdown = this.nextElementSibling;
							dropdown.style.display = dropdown.style.display === 'block' ? 'none'
									: 'block';
						});

		// 페이지의 다른 부분 클릭 시 드롭다운 닫기
		window.addEventListener('click', function(event) {
			if (!event.target.matches('.menu-icon')) {
				var dropdowns = document
						.getElementsByClassName('dropdown-content');
				for (var i = 0; i < dropdowns.length; i++) {
					var openDropdown = dropdowns[i];
					if (openDropdown.style.display === 'block') {
						openDropdown.style.display = 'none';
					}
				}
			}
		});

		// 삭제 버튼 클릭 이벤트
		document.getElementById('deleteBtn').addEventListener('click',
				function() {
					if (confirm('삭제하시겠습니까?')) {
						// '네' 클릭 시 실행 - 삭제 처리 
						location.href = 'support_Inquiry_Detail.jsp?id=<%= inquiryId %>&action=delete';
					} else {
						// '아니오' 클릭 시 아무 작업도 수행하지 않음 (현재 페이지에 머무름)
						return false;
					}
				});
	</script>
</body>
</html>