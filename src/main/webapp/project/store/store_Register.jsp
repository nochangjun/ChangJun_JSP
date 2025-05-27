<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
    String loginId = (String) session.getAttribute("idKey");
	if (loginId == null) {
	    response.sendRedirect(request.getContextPath() + "/project/login/login.jsp");
	    return;
	}
    System.out.println("로그인 세션 idKey: " + loginId); // 콘솔 확인용
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>가게 등록</title>
	<link rel="stylesheet" href="../css/store_Register.css">
	<jsp:include page="../header.jsp" />
	
	<script>
		function logout() {
			window.location.href = '../login/logoutProcess.jsp';
		}
	    document.addEventListener("DOMContentLoaded", function () {
	        //이미지 등록 버튼 기능
	        document.getElementById('imageUploadBtn').addEventListener('click', function () {
	            document.getElementById('imageFile').click();
	        });
	
	        //파일 선택 시 이미지 미리보기
	        document.getElementById('imageFile').addEventListener('change', function () {
	            const preview = document.getElementById('preview');
	
	            if (this.files && this.files[0]) {
	                const reader = new FileReader();
	
	                reader.onload = function (e) {
	                    //기존 미리보기 내용 제거
	                    preview.innerHTML = '';
	
	                    //이미지 엘리먼트 생성 및 추가
	                    const img = document.createElement('img');
	                    img.src = e.target.result;
	                    img.className = 'preview-image';
	                    preview.appendChild(img);
	
	                    //미리보기 컨테이너 스타일 업데이트
	                    document.getElementById('preview-container').classList.add('has-image');
	                };
	
	                reader.readAsDataURL(this.files[0]);
	            }
	        });
	        
	    	// 이미지 등록 여부 확인 (폼 제출 시)
	        document.querySelector("form").addEventListener("submit", function (event) {
	        	const imageFile = document.getElementById("imageFile");
	            if (!imageFile.files || imageFile.files.length === 0) {
	                alert("대표 이미지를 등록해주세요.");
	                event.preventDefault(); // 제출 방지
	            }
	        });
	    });
	</script>
</head>
<body>
	<!-- 가게 등록 폼 부분 -->
	<div class="register-container">
		<h2 class="register-title">가게 등록</h2>
		<hr class="register-divider">

		<form action="<%=request.getContextPath()%>/project/StoreRegisterServlet" method="post" enctype="multipart/form-data">
			<div class="form-item">
				<label for="storeName">가게 이름</label> <input type="text"
					id="storeName" name="storeName" class="form-input" placeholder="가게 이름을 입력하세요" required>
			</div>
			
			<div class="form-item">
				<label for="address">도로명 주소</label> <input type="text" id="address"
					name="address" class="form-input" placeholder="도로명 주소를 입력하세요" required>
			</div>
			
			<div class="form-item horizontal-group">
			    <div class="form-subitem">
			        <label for="latitude">위도</label>
			        <input type="text" id="latitude" name="latitude" class="form-input" placeholder="예) 35.144318617851724" required>
			    </div>
			    <div class="form-subitem">
			        <label for="longitude">경도</label>
			        <input type="text" id="longitude" name="longitude" class="form-input" placeholder="예) 129.03650386008644" required>
			    </div>
			</div>
			
			<div class="form-item">
			    <label for="city">시</label>
			    <input type="text" id="city" name="city" class="form-input" placeholder="예) 제주시, 서귀포시" required>
			</div>
			
			<div class="form-item">
			    <label for="town">읍/면/동</label>
			    <input type="text" id="town" name="town" class="form-input" placeholder="예) 성산읍, 남원읍, 중문동" required>
			</div>
			
			<div class="form-item">
			    <label for="description">소개</label>
			    <input type="text" id="description" name="description" class="form-input" placeholder="가게 소개를 입력하세요" required>
			</div>

			<div class="form-item">
				<label for="phone">연락처</label> <input type="text" id="phone"
					name="phone" class="form-input" placeholder="연락처를 입력하세요" required>
			</div>

			<div class="form-item">
				<label for="representImage">대표 이미지</label>
				<div class="image-upload-container">
					<div id="preview-container" class="preview-container">
						<!-- 이미지 미리보기 영역 -->
						<div id="preview" class="preview">+</div>
					</div>
					<div class="upload-button-container">
						<button type="button" id="imageUploadBtn" class="image-upload-btn">이미지 등록하기</button>
						<input type="file" id="imageFile" name="imageFile" accept="image/*" style="display: none">
					</div>
				</div>
			</div>
			
			<div class="form-item">
			    <label for="hashtag">해시태그</label>
			    <input type="text" id="hashtag" name="hashtag" class="form-input" placeholder="예) 맛집, 카페, 디저트" required>
			</div>
			

			<div class="submit-wrapper">
				<button type="submit" class="submit-btn" style="margin-top:20px; margin-bottom: 10px;">제출하기</button>
			</div>
		</form>
	</div>
	

	<!-- 푸터 include -->
	<jsp:include page="../footer.jsp" />
	
	<%-- 메시지 alert 처리용 스크립트 --%>
	<%
	    String message = (String) request.getAttribute("message");
	    String redirectUrl = (String) request.getAttribute("redirectUrl");
	    if (message != null && redirectUrl != null) {
	%>	
	<script>
	    alert("<%= message %>");
	    window.location.href = "<%= redirectUrl %>";
	</script>
	<%
	    }
	%>
</body>
</html>