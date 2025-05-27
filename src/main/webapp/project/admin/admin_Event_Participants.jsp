<!-- admin_Event_Participants.jsp-->
<%@ page contentType="text/html; charset=UTF-8" %>
<%
	request.setCharacterEncoding("UTF-8");
	String result = request.getParameter("result"); // 등록 결과(success/fail)
%>
<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>당첨자 등록 - YUMMY JEJU</title>
	<link rel="stylesheet" href="../css/admin_Event_Participants.css">
	<script>
		function validateForm() {
			// 필요한 유효성 검사 추가
			return true;
		}
	</script>
</head>
<body>
	<!-- 사이드바 및 헤더 인클루드 -->
	<%@ include file="../admin_Header.jsp" %>

	<!-- 메인 컨텐츠 영역 -->
	<div class="main-content">
		<!-- 당첨자 등록 섹션 - 향상된 UI -->
		<section class="event-section">
			<h2>이벤트 등록/관리</h2>
			
			<!-- 탭 메뉴 - 기존 위치 유지 -->
			<div class="tabs">
				<a href="admin_Event_Register.jsp" class="tab-btn">이벤트 등록</a>
				<a href="admin_Event_Participants.jsp" class="tab-btn active">당첨자 등록</a>
				<a href="admin_Event_Delete.jsp" class="tab-btn">삭제</a>
			</div>

			<!-- 결과 메시지 - 향상된 UI -->
			<% if ("success".equals(result)) { %>
				<p style="color: green;">✅ 당첨자가 등록되었습니다.</p>
			<% } else if ("fail".equals(result)) { %>
				<p style="color: red;">❌ 등록에 실패했습니다. 입력값을 확인하세요.</p>
			<% } %>

			<!-- 당첨자 등록 폼 - 향상된 UI -->
			<form class="event-form" method="post" action="<%=request.getContextPath()%>/project/admin/eventWinnerRegister" onsubmit="return validateForm()">
				<div class="form-group">
					<label>이벤트 이름</label>
					<input type="text" name="title">
				</div>

				<div class="form-group">
					<label>당첨자 정보</label>
					<textarea name="content"></textarea>
				</div>

				<button type="submit" class="submit-btn">당첨자 등록</button>
			</form>
		</section>
	</div>
</body>
</html>