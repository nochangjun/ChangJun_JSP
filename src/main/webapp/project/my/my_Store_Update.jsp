<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="project.MemberMgr, project.MemberBean"%>
<%@ page import="project.RestaurantMgr, project.RestaurantBean" %>
<%
    String memberId = (String) session.getAttribute("idKey");
	String loginType = (String) session.getAttribute("loginType"); // loginType을 세션에서 가져옴
    if (memberId == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }
    
 	// 회원 정보 조회
    MemberMgr mgr = new MemberMgr();
    MemberBean member = mgr.getMember(memberId);
    
    // 가게 정보 조회
    RestaurantMgr rstMgr = new RestaurantMgr();
    RestaurantBean store = rstMgr.getRestaurantByMemberId(memberId);
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
		setupImagePreview();
		
		// 수정 성공 시 알림창 표시
		const urlParams = new URLSearchParams(window.location.search);
		if (urlParams.get("updated") === "true") {
			alert("가게 정보가 성공적으로 수정되었습니다.");
			// URL에서 파라미터 제거 (선택)
			history.replaceState({}, document.title, location.pathname);
		}
	};
	
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

	function setupImagePreview() {
		const fileInput = document.getElementById('imageFile');
		const previewImage = document.getElementById('preview');
		const defaultPreview = document.getElementById('default-preview');

		document.getElementById('imageUploadBtn').addEventListener('click', function () {
			fileInput.click();
		});

		fileInput.addEventListener('change', function (e) {
			const file = e.target.files[0];
			if (file) {
				const reader = new FileReader();
				reader.onload = function (event) {
					previewImage.src = event.target.result;
					previewImage.style.display = 'block';
					defaultPreview.style.display = 'none';
				};
				reader.readAsDataURL(file);
			}
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
					<% if (!"naver".equals(loginType)) { %>
					    <li>비밀번호 변경</li>
					<% } %>
					<li>회원탈퇴</li>
					<% if ("가게사장".equals(member.getMember_role())) { %>
						<li class="active">가게정보수정</li>
					<%} %>
				</ul>
			</div>

			<div class="main-content">
				<div class="section-title">
					<h2>▶ 가게정보수정</h2>
				</div>
				<% if (store == null) { %>
			        <div class="no-store-message">
			            <p style="line-height: 1.6; color: #FF2424; font-size: 16px;">
			                가게 정보가 존재하지 않습니다.<br>가게 등록 후 수정이 가능합니다.
			            </p>
			        </div>
				<% } else if ("대기".equals(store.getRst_status())) { %>
			        <div class="approval-waiting-message">
			            <p style="line-height: 1.6; color: #555; font-size: 16px;">현재 가게 등록이 승인 대기중입니다.<br>관리자의 승인이 완료되면 수정이 가능합니다.</p>
			        </div>
			    <% } else if ("승인".equals(store.getRst_status())) { %>
		    		<form action="<%=request.getContextPath() %>/project/updateRestaurant"
						method="post" enctype="multipart/form-data">
						
						<input type="hidden" name="rst_id" value="<%= store.getRst_id() %>">
	    				<input type="hidden" name="rst_status" value="승인">
	
						<div class="form-group">
					        <div class="form-label store-form-label">가게 이름</div>
					        <input type="text" name="rst_name" class="form-control-store" value="<%= store.getRst_name() %>" required>
					    </div>
	
						<div class="form-group">
					        <div class="form-label store-form-label">도로명 주소</div>
					        <input type="text" name="rst_address" class="form-control-store" value="<%= store.getRst_address() %>" required>
					    </div>
	
						<div class="form-group">
						    <div class="form-label store-form-label">위도</div>
						    <input type="text" name="rst_lat" class="form-control-store" value="<%= store.getRst_lat() %>" required>
						</div>
						
						<div class="form-group">
						    <div class="form-label store-form-label">경도</div>
						    <input type="text" name="rst_long" class="form-control-store" value="<%= store.getRst_long() %>" required>
						</div>
	
						<div class="form-group">
						    <div class="form-label store-form-label">시</div>
						    <input type="text" name="regionLabel" class="form-control-store" value="<%= store.getRegionLabel() %>" required>
						</div>
	
						<div class="form-group">
						    <div class="form-label store-form-label">읍/면/동</div>
						    <input type="text" name="region2Label" class="form-control-store" value="<%= store.getRegion2Label() %>" required>
						</div>
	
						<div class="form-group">
					        <div class="form-label store-form-label">가게 소개</div>
					        <input type="text" name="rst_introduction" class="form-control-store" value="<%= store.getRst_introduction() %>" required>
					    </div>
	
						<div class="form-group">
					        <div class="form-label store-form-label">연락처</div>
					        <input type="text" name="rst_phonenumber" class="form-control-store" value="<%= store.getRst_phonenumber() %>" required>
					    </div>
	
						<div class="form-group">
					        <div class="form-label store-form-label">대표 이미지</div>
					        <div class="image-upload-box">
					            <div id="preview-container" class="preview-container">
					                <img id="preview" class="preview-image"
					                     src="<%= (store.getImgpath() != null && !store.getImgpath().isEmpty()) ? request.getContextPath() + store.getImgpath() : "#" %>"
					                     style="<%= (store.getImgpath() != null && !store.getImgpath().isEmpty()) ? "" : "display:none;" %>">
					                <div id="default-preview" class="preview-placeholder"
					                     style="<%= (store.getImgpath() == null || store.getImgpath().isEmpty()) ? "" : "display:none;" %>">+</div>
					            </div>
					            <div class="upload-controls">
					                <button type="button" id="imageUploadBtn" class="image-upload-btn">이미지 수정하기</button>
					                <input type="file" id="imageFile" name="imageFile" accept="image/*" style="display: none">
					            </div>
					        </div>
					    </div>
	
						<div class="form-group">
					        <div class="form-label store-form-label">해시태그</div>
					        <input type="text" name="rst_tag" class="form-control-store" value="<%= store.getRst_tag() %>" required>
					    </div>
	
						<div class="withdraw-button-wrapper">
							<button type="submit" class="btn">수정하기</button>
						</div>
					</form>
			    <% } %>
			</div>
		</div>
	</div>
</div>

	<!-- Footer 포함 -->
	<jsp:include page="../footer.jsp" />
</body>
</html>