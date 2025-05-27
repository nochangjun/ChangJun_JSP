<%@page import="project.MemberMgr"%>
<%@page import="project.MenuBean"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="project.RestaurantBean, project.RestaurantMgr" %>

<jsp:useBean id="menuBean" class="project.MenuBean"/>
<jsp:useBean id="menuMgr" class="project.MenuMgr"/>

<%
    String id = (String)session.getAttribute("idKey");
    if(id == null || id.trim().equals("")){
        String currentURL = request.getRequestURI();
        response.sendRedirect("../login/login.jsp?url=" + currentURL);
        return;
    }

    String rstr_id = request.getParameter("rst_id");
	if (rstr_id == null || rstr_id.trim().equals("")) {
	    out.println("<script>");
	    out.println("alert('잘못된 접근입니다.');");
	    out.println("location.href='../main.jsp';");
	    out.println("</script>");
	    return;
	}
	
	int rst_id = Integer.parseInt(rstr_id);
    RestaurantMgr mgr = new RestaurantMgr();
    RestaurantBean RstBean = mgr.getRestaurantDetail(rst_id);
    List<MenuBean> menuList = menuMgr.getMenuList(rst_id);
    
 // 회원의 제한 상태 가져오기
    MemberMgr memberMgr = new MemberMgr();
    boolean isBanned = memberMgr.isBannedFromReview(id);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>리뷰 작성</title>
    <link rel="stylesheet" href="../css/rst_review_Write.css">
</head>
<body>

<%-- 제한된 사용자는 리뷰 작성 버튼 비활성화 --%>
<% if (isBanned) { %>
    <div class="restricted-message">
        <p>현재 신고 처리로 인해, 3일간 리뷰를 작성할 수 없습니다.</p>
    </div>
    <button class="submit-button" disabled>리뷰 작성 제한</button>
<% } else { %>
<form action="ReviewWriteServlet" method="post" onsubmit="return prepareSubmission();" enctype="multipart/form-data">

    <div class="container">
        <div class="heading">리뷰 작성</div>

        <div class="product-card">
            <%
			    String mainImg = RstBean.getImgpath();
			    boolean isExternalImg = mainImg != null && (mainImg.startsWith("http://") || mainImg.startsWith("https://"));
			    String resolvedImg = (mainImg != null && !mainImg.trim().isEmpty()) 
			        ? (isExternalImg ? mainImg : request.getContextPath() + "/" + mainImg)
			        : request.getContextPath() + "/img/photoready.png";
			%>
			<img src="<%= resolvedImg %>" alt="음식 이미지" class="product-image">
            <div class="product-info">
                <div class="product-name"><%=RstBean.getRst_name() %></div>
                <div class="product-desc"><%=RstBean.getRst_address() %></div>
                <div class="product-desc"><%=RstBean.getRst_phonenumber() %></div>
                <div class="product-desc"><%=RstBean.getRst_introduction() %></div>
            </div>
        </div>

        <div class="menu-select-section">
            <div class="menu-title">드신 메뉴를 선택해 주세요</div>
            <div class="menu-list">
                <% for(MenuBean menu : menuList) { %>
                    <div class="menu-item" onclick="selectMenu('<%=menu.getMenu_name()%>', this)">
                        <%=menu.getMenu_name()%> (<%=menu.getMenu_price()%>)
                    </div>
                <% } %>
            </div>
        </div>

        <div class="rating-container">
            <div class="rating-title">별점주기</div>
            <div class="stars">
                <div class="star" data-index="1">★</div>
                <div class="star" data-index="2">★</div>
                <div class="star" data-index="3">★</div>
                <div class="star" data-index="4">★</div>
                <div class="star" data-index="5">★</div>
            </div>
        </div>

        <div class="photo-upload">
            <h3>사진을 추가해 주세요</h3>
            <div style="font-size: 10px; color: #999999;">
                해당 음식점에서 찍은 사진을 첨부해야만 리뷰가 작성됩니다
            </div>
            <input type="file" name="review_photos" id="photoInput" accept="image/*" multiple style="display: none;">
            <button type="button" class="upload-button" onclick="document.getElementById('photoInput').click();">+</button>
            <div id="previewContainer" style="margin-top: 10px;"></div>
        </div>

        <div class="comment-section">
            <textarea class="comment-box" name="review_content" maxlength="200" placeholder="리뷰를 작성해 주세요. 욕설, 비방은 삼가주세요."></textarea>
            <div class="comment-info"><span id="charCount">0</span>/200</div>
        </div>

        <button type="submit" class="submit-button" disabled>등록</button>
    </div>
    
    <input type="hidden" name="rst_id" value="<%=rst_id %>">
    <input type="hidden" name="review_menu" id="reviewMenuInput">
    <input type="hidden" name="rating" id="ratingInput">
    <input type="hidden" name="lat" id="latitudeInput">
    <input type="hidden" name="lon" id="longitudeInput">
    <input type="hidden" name="photo_date" id="photoDateInput">
</form>
<% } %>
<!-- EXIF 데이터를 읽기 위한 라이브러리 -->
<script src="https://cdn.jsdelivr.net/npm/exifreader@4.12.0/dist/exif-reader.min.js"></script>
<script>
// 리뷰 작성에 필요한 변수들 초기화
let rating = 0;                    // 별점
let selectedMenus = [];           // 선택된 메뉴 목록
let gpsValid = false;             // GPS 유효성
let dateValid = false;            // 촬영일자 유효성
let commentValid = false;         // 댓글(리뷰 내용) 유효성

// 자주 사용하는 요소를 변수에 담기
const stars = document.querySelectorAll('.star');                // 별점 아이콘들
const submitBtn = document.querySelector(".submit-button");      // 등록 버튼
const textarea = document.querySelector(".comment-box");         // 리뷰 내용 textarea
const charCount = document.getElementById("charCount");          // 글자 수 카운터
const photoInput = document.getElementById('photoInput');        // 사진 업로드 input
const previewContainer = document.getElementById('previewContainer');  // 사진 미리보기 컨테이너
let isBanned = <%= isBanned ? "true" : "false" %>; // 제한 상태

// 음식점 위도/경도 (JSP에서 받아오는 값)
const rstLat = <%=RstBean.getRst_lat()%>;
const rstLon = <%=RstBean.getRst_long()%>;

/* ✅ 전체 리뷰 등록 조건을 검사해서 등록 버튼을 활성화/비활성화 */
function validateForm() {
    const isValid = selectedMenus.length > 0 && rating > 0 && gpsValid && dateValid && commentValid;
    submitBtn.disabled = !isValid || isBanned; // 모든 조건이 맞으면 버튼 활성화
}

validateForm(); // 페이지 로딩 시 검증

/* ⭐ 별점 클릭 이벤트 처리 */
stars.forEach(star => {
    star.addEventListener('click', function () {
        rating = parseInt(this.dataset.index); // 클릭한 별점 저장
        updateStars();                         // 별 UI 업데이트
        validateForm();                        // 유효성 검사
    });
});

/* ⭐ 클릭된 별까지 색상 표시 */
function updateStars() {
    stars.forEach((star, index) => {
        star.classList.toggle('active', index < rating);
    });
}

/* 🍽️ 메뉴 선택 및 해제 처리 */
window.selectMenu = function(menuName, element) {
    const idx = selectedMenus.indexOf(menuName);

    if (idx === -1) {
        // 선택되지 않은 경우 → 추가
        selectedMenus.push(menuName);
        element.classList.add("selected");
    } else {
        // 이미 선택된 경우 → 제거
        selectedMenus.splice(idx, 1);
        element.classList.remove("selected");
    }

    // 숨겨진 input에 메뉴 목록 저장 (서버 전송용)
    document.getElementById("reviewMenuInput").value = selectedMenus.join(", ");
    validateForm(); // 유효성 검사
}

/* ✍️ 리뷰 내용 입력 시 글자 수 확인 및 유효성 체크 */
textarea.addEventListener("input", function () {
    charCount.textContent = this.value.length;
    commentValid = this.value.trim().length > 0; // 공백만 입력된 경우 false
    validateForm();
});

/* 📤 폼 전송 전에 별점 값을 숨겨진 input에 설정 */
window.prepareSubmission = function () {
    document.getElementById("ratingInput").value = rating;
    return true;
}

function prepareSubmission() {
    document.getElementById("ratingInput").value = document.querySelector(".stars .active").dataset.index;
    return true;
}

/* 📍 두 지점 간의 거리 계산 (단위: 미터) */
function getDistanceFromLatLonInMeters(lat1, lon1, lat2, lon2) {
    const R = 6371000; // 지구 반지름 (m)
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) ** 2 +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLon / 2) ** 2;
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}

/* 🖼️ 사진 업로드 및 EXIF 정보 추출 */
photoInput.addEventListener('change', function (event) {
    const files = event.target.files;
    previewContainer.innerHTML = ''; // 미리보기 초기화

    // 유효성 초기화
    gpsValid = false;
    dateValid = false;
    validateForm();

    // 최대 5장까지만 처리
    for (let i = 0; i < Math.min(files.length, 5); i++) {
        const file = files[i];
        if (!file.type.startsWith('image/')) continue;

        // 미리보기 이미지 표시
        const reader = new FileReader();
        reader.onload = function (e) {
            const img = document.createElement('img');
            img.src = e.target.result;
            img.style.maxWidth = '100px';
            img.style.margin = '5px';
            img.style.borderRadius = '10px';
            img.style.objectFit = 'cover';
            previewContainer.appendChild(img);
        };
        reader.readAsDataURL(file);

        // EXIF 데이터 추출
        const exifReader = new FileReader();
        exifReader.onload = async function (e) {
            try {
                const tags = await ExifReader.load(e.target.result);

                // GPS 정보 추출
                if (tags['GPSLatitude'] && tags['GPSLongitude']) {
                    const photoLat = parseFloat(tags['GPSLatitude'].description);
                    const photoLon = parseFloat(tags['GPSLongitude'].description);

	        console.log("📍 사진 위도:", photoLat);
                    console.log("📍 사진 경도:", photoLon);

                    // hidden input에 저장
                    document.getElementById('latitudeInput').value = photoLat;
                    document.getElementById('longitudeInput').value = photoLon;

                    // 음식점과의 거리 계산
                    const distance = getDistanceFromLatLonInMeters(photoLat, photoLon, rstLat, rstLon);
	        console.log("📏 거리:", distance.toFixed(2), "m");
                    gpsValid = distance <= 500; // 100m 이내면 true
                } else {
                    gpsValid = false;
                }

                // 촬영 날짜 유효성 확인
                if (tags['DateTimeOriginal']) {
                    const photoDateRaw = tags['DateTimeOriginal'].description;

                    // 날짜 포맷 수정 (YYYY-MM-DDTHH:mm:ss 형태로 변환)
                    const formattedPhotoDateStr = photoDateRaw.replace(/^(\d{4}):(\d{2}):(\d{2})/, '$1-$2-$3').replace(' ', 'T');
                    const photoDate = new Date(formattedPhotoDateStr);
	        
	       console.log("🕒 촬영일시:", photoDate);

                    if (!isNaN(photoDate.getTime())) {
                        const today = new Date();
                        const diffTime = today - photoDate;
                        const diffDays = diffTime / (1000 * 60 * 60 * 24); // 일수 차이

                        // 3일 이내 촬영된 경우에만 통과
                        if (diffDays <= 3) {
                            dateValid = true;
                            document.getElementById('photoDateInput').value = photoDateRaw;
                        } else {
                            dateValid = false;
                        }
                    } else {
                        dateValid = false;
                    }
                } else {
                    dateValid = false;
                }

                // 모든 정보 업데이트 후 유효성 체크
                validateForm();

            } catch (err) {
                console.log("EXIF 처리 오류:", err);
                gpsValid = false;
                dateValid = false;
                validateForm();
            }
        };
        exifReader.readAsArrayBuffer(file); // EXIFReader는 ArrayBuffer로 읽어야 함
    }
});
</script>

</body>
</html>
