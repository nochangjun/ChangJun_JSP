<%@page contentType="text/html; charset=UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>나의 맛집</title>
<link rel="stylesheet" href="../css/my_Favorites.css">
</head>
<body>
	<!-- Header 포함 -->
	<jsp:include page="../header.jsp" />

	<div class="container">
		<h1>나의 맛집</h1>

		<div class="profile-section">
			<div class="profile-img">
				<img id="profile-image" src="../img/구머링.png" alt="프로필 이미지">
			</div>

			<div class="stats-section">
				<div class="section-title">구머링님의 제주여행</div>

				<div class="stats-grid">
					<div class="stats-item">
						나의 맛집일정 <span>0</span>
					</div>
					<div class="stats-item">
						찜한 즐겨찾기 <span>0</span>
					</div>
					<div class="stats-item">
						찜한 맛집일정 <span>0</span>
					</div>
					<div class="stats-item">
						방문 맛집 <span>0</span>
					</div>
					<div class="stats-item">
						찜한 맛집 <span>0</span>
					</div>
				</div>
			</div>
		</div>

		<div class="favorite-section">
			<h2>
				찜한 즐겨찾기 <small>내가 즐겨찾기한 장소를 확인할 수 있습니다</small>
			</h2>

			<div class="tabs">
				<div class="tab">찜한 맛집(0)</div>
				<div class="tab active">찜한 즐겨찾기(0)</div>
			</div>

			<div class="empty-notice">
				<i class="exclamation-mark">!</i>
				<p>등록된 정보가 없습니다</p>
			</div>
		</div>
	</div>

	<script>
// 탭 전환 기능
document.addEventListener('DOMContentLoaded', function() {
  const tabs = document.querySelectorAll('.tab');
  tabs.forEach((tab, index) => {
    tab.addEventListener('click', () => {
      // 찜한 맛집 탭(인덱스 0)을 클릭했을 때 페이지 이동
      if (index === 0) {
        window.location.href = 'my_Favorites.jsp';
        return; // 페이지 이동 후 아래 코드 실행 방지
      }
      
      // 그 외의 탭 클릭 시 기존 탭 전환 로직 실행
      tabs.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');
      // 실제 구현에서는 여기에 콘텐츠 전환 로직이 들어갑니다
    });
  });
});
</script>

	<!-- Footer 포함 -->
	<jsp:include page="../footer.jsp" />
</body>
</html>