<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="project.MemberMgr, project.MemberBean"%>
<%
		String id = (String) session.getAttribute("idKey");
		String loginType = (String) session.getAttribute("loginType"); // loginType을 세션에서 가져옴
		if (id == null) {
			response.sendRedirect("../login/login.jsp");
			return;
		}
		
		MemberMgr mgr = new MemberMgr();
		MemberBean member = mgr.getMember(id);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>내 정보 관리</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/project/css/my_Common.css">
<jsp:include page="../header.jsp" />
<script>
	// 페이지 로드시 실행
	window.onload = function() {
		setupSidebarNavigation();
	};

	// 네비게이션 설정
	function setupSidebarNavigation() {
		const menuItems = document.querySelectorAll('.sidebar li');
		
		menuItems.forEach(item => {
	        item.addEventListener('click', function () {
	            const text = item.textContent.trim();

	            if (item.classList.contains("active")) return; // 현재 페이지면 이동X

	            if (text.includes("개인정보변경")) {
	                location.href = "<%= loginType.equals("naver") ? "my_Update_Profile_Naver.jsp" : "my_Update_Profile.jsp" %>";
	            } else if (text.includes("비밀번호 변경")) {
	                location.href = "my_Change_Password.jsp";
	            } else if (text.includes("회원탈퇴")) {
	                location.href = "my_Delete_Account.jsp";
	            } else if (text.includes("가게정보수정")) {
	                location.href = "my_Store_Update.jsp";
	            }
	        });
	    });
	}

	// 회원탈퇴 확인 함수
	function confirmWithdrawal() {
		if (confirm('정말로 회원탈퇴를 진행하시겠습니까? 이 작업은 되돌릴 수 없습니다.')) {
	        return true;  // 제출 허용
	    } else {
	        return false; // 제출 차단
	    }
	}
</script>
</head>
<body>

<!-- 스코프 클래스 추가 -->
<div class="my-common-scope">
	<div class="container">
		<h1>내 정보 관리</h1>

		<div class="content-wrapper">
			<div class="sidebar">
				<ul>
					<li>개인정보변경</li>
					<% if (!"naver".equals(loginType)) { %>
					    <li>비밀번호 변경</li>
					<% } %>
					<li class="active">회원탈퇴</li>
					<%if ("가게사장".equals(member.getMember_role())) { %>
						<li>가게정보수정</li>
					<%} %>
				</ul>
			</div>

			<div class="main-content">
				<div class="section-title">
					<h2>▶ 회원탈퇴</h2>
					<!-- <span class="section-description">회원 시에 주어서는 안 될 약속이지만 바랍니다.</span> -->
				</div>

				<form id="withdrawForm" action="my_Delete_Account_Proc.jsp" method="post"
					onsubmit="return confirmWithdrawal()">
					<div class="vertical-box">
						<div class="withdraw-title">회원탈퇴 주의사항</div>
						<ul class="withdraw-notice">
							<li>1. 회원탈퇴 시 회원님은 개인정보는 모두 삭제 처리 됩니다.</li>
							<li>2. 회원탈퇴는 즉시 처리 됩니다.</li>
							<li>3. 회원탈퇴 시 회원님이 등록한 일정, 게시글 등 모두 삭제되며,<br>&nbsp;&nbsp;&nbsp;&nbsp;재가입을
								하더라도 복구되지 않습니다.
							</li>
							<li>4. 해당 ID로 재가입이 불가능합니다.</li>
						</ul>

						<div class="withdraw-button-wrapper">
							<button type="submit" class="btn">회원탈퇴</button>
						</div>
					</div>
				</form>
			</div>
		</div>
	</div>
</div>

	<!-- Footer 포함 -->
	<jsp:include page="../footer.jsp" />
</body>
</html>