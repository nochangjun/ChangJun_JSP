<!-- admin_Event_Register.jsp -->
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
	<title>이벤트 등록/관리 - YUMMY JEJU</title>
	<link rel="stylesheet" href="../css/admin_Event_Register.css">
	<script>
		function previewImage(event) {
			const input = event.target;
			const preview = document.getElementById('preview');
			const uploadText = document.getElementById('uploadText');
	
			if (input.files && input.files[0]) {
				const reader = new FileReader();
				reader.onload = function (e) {
					preview.src = e.target.result;
					preview.style.display = 'block';
					uploadText.style.display = 'none';
				};
				reader.readAsDataURL(input.files[0]);
			}
		}
	
		function clearPreview() {
			const input = document.getElementById('imageInput');
			const preview = document.getElementById('preview');
			const uploadText = document.getElementById('uploadText');
	
			// 초기화
			input.value = '';
			preview.src = '';
			preview.style.display = 'none';
			uploadText.style.display = 'block';
		}
		
		// 날짜 유효성 검사 함수 추가
		function validateDates() {
			const startDate = new Date(document.querySelector('input[name="start_date"]').value);
			const endDate = new Date(document.querySelector('input[name="end_date"]').value);
			
			if (endDate < startDate) {
				alert("종료일은 시작일보다 뒤여야 합니다.");
				return false;
			}
			return true;
		}
	</script>
</head>
<body>
	<!-- 사이드바 및 헤더 인클루드 -->
	<%@ include file="../admin_Header.jsp" %>

	<!-- 메인 컨텐츠 영역 -->
	<div class="main-content">
		<!-- 이벤트 등록 섹션 - 향상된 UI -->
		<section class="event-section">
			<h2>이벤트 등록/관리</h2>
			
			<!-- 탭 메뉴 - 기존 위치 유지 -->
			<div class="tabs">
				<a href="admin_Event_Register.jsp" class="tab-btn active">이벤트 등록</a>
				<a href="admin_Event_Participants.jsp" class="tab-btn">당첨자 등록</a>
				<a href="admin_Event_Delete.jsp" class="tab-btn">삭제</a>
			</div>

			<!-- 결과 메시지 - 향상된 UI -->
			<% if ("success".equals(result)) { %>
				<p style="color: green;">✅ 이벤트가 등록되었습니다.</p>
			<% } else if ("fail".equals(result)) { %>
				<p style="color: red;">❌ 등록에 실패했습니다. 입력값 또는 이미지 업로드를 확인하세요.</p>
			<% } %>

			<!-- 이벤트 폼 - 향상된 UI -->
			<form class="event-form" method="post" action="eventRegisterProc" enctype="multipart/form-data" onsubmit="return validateDates()">
				<div class="form-group">
					<label>
						이벤트 이름
						<span class="input-guide">(30자 이내 작성)</span>
					</label>
					<input type="text" name="title" maxlength="30" required placeholder="이벤트 제목을 입력하세요">
				</div>

				<div class="form-group">
					<label>이벤트 설명</label>
					<textarea name="content" placeholder="이벤트에 대한 상세 설명을 입력하세요"></textarea>
				</div>

				<div class="form-group">
					<label>대표 이미지</label>
					<div class="image-upload">
						<div class="upload-box" onclick="document.getElementById('imageInput').click();">
							<img id="preview" />
							<span id="uploadText">이미지 업로드</span>
						</div>
						<input type="file" id="imageInput" name="image" accept="image/*" required onchange="previewImage(event)" style="display: none;">
					
						<!-- 컨트롤 버튼들 -->
						<div class="image-buttons">
							<button type="button" onclick="document.getElementById('imageInput').click();">🔄 다시 선택</button>
							<button type="button" onclick="clearPreview()">❌ 삭제</button>
						</div>
					</div>
				</div>

				<div class="form-group">
					<label>이벤트 기간 설정</label>
					<div class="date-inputs">
						<div>
							<span>시작 날짜</span>
							<input type="date" name="start_date" required>
						</div>
						<div>
							<span>종료 날짜</span>
							<input type="date" name="end_date" required>
						</div>
					</div>
				</div>

				<button type="submit" class="submit-btn">이벤트 등록</button>
			</form>
		</section>
	</div>
</body>
</html>