<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="project.MemberMgr, project.MemberBean"%>
<%
		String id = (String) session.getAttribute("idKey");
		if (id == null) {
			response.sendRedirect("../login/login.jsp");
			return;
		}
		
		MemberMgr mgr = new MemberMgr();
		MemberBean member = mgr.getMember(id);
		
		// 본인 인증 여부 확인
		boolean verified = session.getAttribute("verified") != null && (Boolean) session.getAttribute("verified");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>내 정보 관리</title>
<link rel="stylesheet" href="../css/my_Common.css">
<jsp:include page="../header.jsp" />
<script>
	const isVerified = <%= verified %>;
	
	// 페이지 로드시 실행
	window.onload = function() {
		setupSidebarNavigation();
	};

	// 네비게이션 설정
	function setupSidebarNavigation() {
		const menuItems = document.querySelectorAll('.sidebar li');
		const urls = [
			'my_Update_Profile.jsp',
			'my_Change_Password.jsp',
			'my_Delete_Account.jsp',
			'my_Store_Update.jsp'
		];

		menuItems.forEach(function(item, index) {
			item.addEventListener('click', function() {
				if (!isVerified) {
					alert('본인 확인이 필요합니다. 비밀번호를 입력해주세요.');
					return;
				}
				window.location.href = urls[index];
			});
		});
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
					<li>비밀번호 변경</li>
					<li>회원탈퇴</li>
					<%if ("가게사장".equals(member.getMember_role())) { %>
						<li>가게정보수정</li>
					<%} %>
				</ul>
			</div>

			<div class="main-content center-align">
				<div class="verify-title-wrapper">
					<h3>본인확인</h3>
					<p class="verify-description">고객님의 소중한 개인정보보호를 위해서 본인확인을
						진행합니다.</p>
				</div>

				<form action="my_Chk_Proc.jsp" method="post">
					<div class="verify-input-wrapper">
						<div class="verify-label">비밀번호</div>
						<input type="password" class="verify-input" name="password"
							required>
						<button type="submit" class="btn">확인</button>
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