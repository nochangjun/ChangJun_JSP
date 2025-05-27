<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="project.MemberMgr, project.MemberBean"%>
<%
		String id = (String) session.getAttribute("idKey");
		String loginType = (String) session.getAttribute("loginType");  // 세션에서 로그인 타입 확인

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
    const contextPath = "<%= request.getContextPath() %>";
</script>
<script src="../js/my_Update_Profile.js"></script>
</head>
<body>

<!-- 스코프 클래스 추가 -->
<div class="my-common-scope">
	<div class="container">
		<h1>내 정보 관리</h1>

		<div class="content-wrapper">
			<div class="sidebar">
				<ul>
					<li class="active">개인정보변경</li>
					<li>비밀번호 변경</li>
					<li>회원탈퇴</li>
					<%if ("가게사장".equals(member.getMember_role())) { %>
						<li>가게정보수정</li>
					<%} %>
				</ul>
			</div>

			<div class="main-content">
				<div class="section-title">
					<h2>▶ 개인정보변경</h2>
					<span class="section-description">고객님의 개인정보보호를 위해 최신화
						되어있습니다.</span>
				</div>

				<form action="my_Update_Profile_Proc.jsp" method="post"
					enctype="multipart/form-data" onsubmit="return validateForm()">
					<div class="form-group">
						<div class="form-label store-form-label" style="min-width: 100px;">프로필
							이미지</div>
						<div class="image-upload-box">
							<div id="preview-container" class="preview-container">
							    <img id="preview" class="preview-image"
							        src="<%= (member.getMember_image() != null && !member.getMember_image().isEmpty()) 
							                ? (request.getContextPath() + "/upload/profile/" + member.getMember_image()) 
							                : (request.getContextPath() + "/project/img/구머링.png") %>"
							        alt="미리보기" style="display: block;">
							    <div id="default-preview" class="preview-placeholder" style="display: none;">+</div>
							</div>
							<div class="upload-controls">
								<button type="button" id="imageUploadBtn" class="image-upload-btn">이미지 수정하기</button>
								<button type="button" id="resetToDefaultBtn" class="image-upload-btn">기본이미지로 변경</button>
								<input type="file" id="imageFile" name="imageFile" accept="image/*" style="display: none">
								<input type="hidden" id="resetImageFlag" name="resetImageFlag" value="false">
							</div>
						</div>
					</div>

					<div class="form-group">
						<div class="form-label profile-form-label">아이디</div>
						<input type="text" class="form-control-store" style="width: 379px"
							name="userId" value="<%=member.getMember_id()%>" readonly>
					</div>

					<div class="form-group">
						<div class="form-label profile-form-label">이름</div>
						<input type="text" class="form-control-store" style="width: 379px"
							name="userName" value="<%=member.getMember_name()%>" readonly>
					</div>

					<div class="form-group" style="flex-direction: column; align-items: flex-start;">
					    <div style="display: flex; align-items: center; margin-bottom: 4px;">
					        <div class="form-label profile-form-label" style="width: 50px;">닉네임</div>
					        <div style="display: flex; align-items: center;">
					            <input type="text" id="userNickname" name="userNickname"
					                   class="form-control-store" style="width: 284px;"
					                   value="<%=member.getMember_nickname()%>" data-original="<%=member.getMember_nickname()%>">
					            <button type="button" class="check-btn" onclick="checkDuplicate('nickname')">중복확인</button>
					        </div>
					    </div>
					    <div style="margin-left: 60px;">
					        <small id="nicknameMessage" class="info-msg"></small>
					    </div>
					</div>
					
					
					<div class="form-group" style="flex-direction: column; align-items: flex-start;">
					    <div style="display: flex; align-items: center; margin-bottom: 4px;">
					        <div class="form-label profile-form-label" style="width: 50px;">휴대폰</div>
					        <div style="display: flex; align-items: center;">
					            <input type="text" id="userPhone" name="userPhone"
					                   class="form-control-store" style="width: 284px;"
					                   value="<%=member.getMember_phone()%>" data-original="<%=member.getMember_phone()%>">
					            <button type="button" class="check-btn" onclick="checkDuplicate('phone')">중복확인</button>
					        </div>
					    </div>
					    <div style="margin-left: 60px;">
					        <small id="phoneMessage" class="info-msg"></small>
					    </div>
					</div>

					<div class="form-group" style="flex-direction: column; align-items: flex-start;">
					    <div style="display: flex; align-items: center; margin-bottom: 4px;">
					        <div class="form-label profile-form-label" style="width: 50px;">이메일</div>
					        <div style="display: flex; align-items: center;">
					            <input type="email" id="userEmail" name="userEmail"
					                   class="form-control-store" style="width: 284px;"
					                   value="<%=member.getMember_email()%>" data-original="<%=member.getMember_email()%>">
					            <button type="button" class="check-btn" onclick="checkDuplicate('email')">중복확인</button>
					        </div>
					    </div>
					    <div style="margin-left: 60px;">
					        <small id="emailMessage" class="info-msg"></small>
					    </div>
					</div>

					<div class="withdraw-button-wrapper">
						<button type="submit" class="btn">저장</button>
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