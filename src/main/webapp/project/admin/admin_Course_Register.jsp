<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<%@page import="java.util.Vector"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.sql.*, org.json.JSONArray" %>
<%@ page import="project.AdminCourseBean, project.AdminCourseMgr" %>
<%@ page import="project.RestaurantMgr, project.RestaurantBean" %>
<%
    request.setCharacterEncoding("UTF-8");

    String action = request.getParameter("action");
    String contentType = request.getContentType();
    boolean isMultipart = contentType != null && contentType.toLowerCase().startsWith("multipart/");
    System.out.println("Content-Type: " + contentType);
    System.out.println("isMultipart: " + isMultipart);

    // -------------------- [1] 맛집 검색 --------------------
    if ("searchRestaurant".equals(action)) {
        String keyword = request.getParameter("keyword");
        if (keyword == null || keyword.trim().isEmpty()) {
            out.print("[]");
            return;
        }
        keyword = "%" + keyword.trim() + "%";

        RestaurantMgr rstMgr = new RestaurantMgr();
        Vector<RestaurantBean> searchList = rstMgr.getRestaurantListByKeyword(keyword);

        StringBuilder json = new StringBuilder();
        json.append("[");
        boolean first = true;
        for (RestaurantBean rb : searchList) {
            if (!first) json.append(",");
            json.append("{")
                .append("\"rst_id\":").append(rb.getRst_id()).append(",")
                .append("\"rst_name\":\"").append(rb.getRst_name().replace("\"", "\\\"")).append("\",")
                .append("\"rst_address\":\"").append(rb.getRst_address().replace("\"", "\\\"")).append("\",")
                .append("\"rst_lat\":").append(rb.getRst_lat()).append(",")
                .append("\"rst_long\":").append(rb.getRst_long()).append(",")
                .append("\"imgpath\":\"").append(rb.getImgpath().replace("\"", "\\\"")).append("\"")
                .append("}");
            first = false;
        }
        json.append("]");
        out.print(json.toString());
        return;
    }

    // -------------------- [2] 코스 등록 --------------------
    if (isMultipart) {
        String uploadPath = application.getRealPath("/") + "upload" + File.separator;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        MultipartRequest multi = new MultipartRequest(
            request, 
            uploadPath, 
            10 * 1024 * 1024,  // 10MB 제한
            "UTF-8",
            new DefaultFileRenamePolicy()
        );

        String courseTitle = multi.getParameter("course_name");
        String description = multi.getParameter("description");
        String tagsJson = multi.getParameter("tags_json");
        String stores = multi.getParameter("stores_json");
        String imageFileName = multi.getFilesystemName("image_file");

        System.out.println("======== [코스 등록 요청 - cos.jar] ========");
        System.out.println("courseTitle: " + courseTitle);
        System.out.println("description: " + description);
        System.out.println("tagsJson: " + tagsJson);
        System.out.println("storesJson: " + stores);
        System.out.println("imageFileName: " + imageFileName);

        // 태그 파싱
        String courseTag = "";
        try {
            if (tagsJson != null && !tagsJson.trim().isEmpty()) {
                JSONArray tagArr = new JSONArray(tagsJson);
                for (int i = 0; i < tagArr.length(); i++) {
                    if (i > 0) courseTag += ",";
                    courseTag += tagArr.getString(i);
                }
            }
        } catch (Exception e) {
            System.out.println("[ERROR] 태그 파싱 오류");
            e.printStackTrace();
        }

        String imagePath = (imageFileName != null) ? "upload/" + imageFileName : null;

        // DB 저장
        AdminCourseBean course = new AdminCourseBean();    
        course.setCourseTitle(courseTitle);
        course.setDescription(description);
        course.setCourseTag(courseTag);
        course.setStores(stores);
        course.setCourseWatch(0);
        course.setCourseLike(0);
        course.setImagePath(imagePath);

        AdminCourseMgr mgr = new AdminCourseMgr();
        boolean result = mgr.insertCourse(course);
        System.out.println("DB insert result: " + result);

        out.print(result ? "success" : "fail");
        System.out.println("======== [코스 등록 완료] ========");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>맛집 추천 코스 등록</title>
    <link rel="stylesheet" type="text/css" href="../css/admin_Course_Register.css">
    <!-- 네이버 지도 API (발급받은 ncpClientId 사용) -->
    <script type="text/javascript" src="https://oapi.map.naver.com/openapi/v3/maps.js?ncpKeyId=s2uzi3murw"></script>
    <script>
        let map;
        let searchMarkers = [];
        let tagList = []; // Initialize as empty for custom tags
        let storeList = [];

        window.onload = function() {
            renderTagTable();
            renderStoreTable();
        };
        
        function cleanString(input) {
            return input
                .replace(/[\u0000-\u001F\u007F-\u009F]/g, '')  // 제어문자 제거
                .replace(/[\u200B-\u200D\uFEFF]/g, '')         // zero-width
                .replace(/[\u202A-\u202E]/g, '')               // 방향 제어
                .replace(/[\r\n\t]/g, '')                      // 줄바꿈, 탭
                .replace(/"/g, '&quot;')                       // 따옴표 대응
                .replace(/'/g, '&#39;')                        // 홑따옴표 대응
                .trim();
        }

        // 태그 테이블 렌더링
        function renderTagTable() {
            const tagTableBody = document.getElementById("tagTableBody");
            tagTableBody.innerHTML = "";
            tagList.forEach((tag, index) => {
                const row = document.createElement("tr");
                const tdTag = document.createElement("td");
                tdTag.textContent = tag;
                const tdDelete = document.createElement("td");
                tdDelete.innerHTML = "<span class='delete-btn'>삭제</span>";
                tdDelete.onclick = function() {
                    tagList.splice(index, 1);
                    renderTagTable();
                };
                row.appendChild(tdTag);
                row.appendChild(tdDelete);
                tagTableBody.appendChild(row);
            });
            const addRow = document.createElement("tr");
            const addTd = document.createElement("td");
            addTd.colSpan = 2;
            addTd.className = "add-row";
            addTd.textContent = "+ 추가";
            addTd.onclick = function() {
                const newTag = prompt("새 태그를 입력하세요 (예: #분위기좋음)");
                if(newTag) { tagList.push(newTag); renderTagTable(); }
            };
            addRow.appendChild(addTd);
            tagTableBody.appendChild(addRow);
        }

        // 선택한 맛집 목록 렌더링
        function renderStoreTable() {
            const storeTableBody = document.getElementById("storeTableBody");
            storeTableBody.innerHTML = "";
            storeList.forEach((store, index) => {
                const row = document.createElement("tr");
                const tdName = document.createElement("td");
                tdName.textContent = (store.order ? store.order + ". " : "") + store.name;
                const tdDelete = document.createElement("td");
                tdDelete.innerHTML = "<span class='delete-btn'>삭제</span>";
                tdDelete.onclick = function() {
                    storeList.splice(index, 1);
                    renderStoreTable();
                };
                row.appendChild(tdName);
                row.appendChild(tdDelete);
                storeTableBody.appendChild(row);
            });
        }

        // 맛집 검색 모달 열기
        function openRestaurantModal() {
            document.getElementById("restaurantModal").style.display = "block";
            initRestaurantSelectMap();
        }
        function closeRestaurantModal() {
            document.getElementById("restaurantModal").style.display = "none";
        }
        function initRestaurantSelectMap() {
            map = new naver.maps.Map('restaurantSelectMap', {
                center: new naver.maps.LatLng(33.499621, 126.531188),
                zoom: 11
            });
            searchMarkers.forEach(marker => marker.setMap(null));
            searchMarkers = [];
        }

        // AJAX로 맛집 검색
        function searchRestaurant() {
            let keyword = document.getElementById("restaurantSearch").value;
            if(keyword.trim() === "") return;
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "admin_Course_Register.jsp?action=searchRestaurant&keyword=" + encodeURIComponent(keyword), true);
            xhr.onreadystatechange = function() {
                if(xhr.readyState === 4 && xhr.status === 200) {
                    console.log("응답 확인:", xhr.responseText);
                    try {
                        let results = JSON.parse(xhr.responseText);
                        displaySearchResults(results);
                        addMarkersToMap(results);
                    } catch(e) {
                        console.error("JSON 파싱 오류:", e);
                    }
                }
            };
            xhr.send();
        }

        // 지도에 검색 결과 마커 추가
        function addMarkersToMap(results) {
            searchMarkers.forEach(marker => marker.setMap(null));
            searchMarkers = [];
            results.forEach((item, index) => {
                const storeName = cleanString(item.rst_name);
                console.log("🔍 최종 확인용 storeName:", storeName);
                console.log("🔎 디버깅용:", [...item.rst_name]);  // 글자 하나하나 배열로 보기

                const htmlContent =
                    '<div style="'
                    + 'display: flex; align-items: center; justify-content: center;'
                    + 'background: rgba(255, 255, 255, 0.95);'
                    + 'border: 1.5px solid #000000;'
                    + 'border-radius: 12px;'
                    + 'padding: 6px 12px;'
                    + 'font-size: 14px;'
                    + 'font-weight: 600;'
                    + 'color: #333;'
                    + 'font-family: "Noto Sans KR", sans-serif;'
                    + 'box-shadow: 0 4px 8px rgba(0,0,0,0.15);'
                    + 'white-space: nowrap;'
                    + 'transition: transform 0.2s ease;'
                    + '">'
                    + '<span>' + storeName + '</span>'
                    + '</div>';

                const marker = new naver.maps.Marker({
                    position: new naver.maps.LatLng(item.rst_lat, item.rst_long),
                    map: map,
                    icon: {
                        content: htmlContent,
                        anchor: new naver.maps.Point(0, 0)
                    }
                });

                // 마커 클릭 시 storeList에 추가하는 이벤트
                naver.maps.Event.addListener(marker, "click", function() {
                    if(storeList.length >= 5) {
                        alert("최대 5개까지 추가 가능합니다.");
                        return;
                    }
                    if(storeList.length >= 3) {
                        if(!confirm("추가 하시겠습니까?")) {
                            alert("추가하지 않습니다.");
                            return;
                        }
                    }
                    addStore(item.rst_id, item.rst_name, item.rst_lat, item.rst_long, item.imgpath);
                });
                searchMarkers.push(marker);
            });
            if(results.length > 0) {
                let center = new naver.maps.LatLng(results[0].rst_lat, results[0].rst_long);
                map.setCenter(center);
            }
        }

        // 맛집을 코스에 추가
        function addStore(rst_id, name, lat, lng, image) {
            // 중복 추가 방지
            for(let i = 0; i < storeList.length; i++){
                if(storeList[i].rst_id == rst_id) return;
            }
            
            // 최대 5개 제한
            if (storeList.length >= 5) {
                alert("최대 5개까지만 등록할 수 있습니다.");
                return;
            }
            
            let newOrder = storeList.length + 1;
            storeList.push({rst_id: rst_id, name: name, lat: lat, lng: lng, image: image, order: newOrder});
            
            alert(newOrder + "번째 음식점이 추가되었습니다.");
            renderStoreTable();
            closeRestaurantModal();
        }

        // 이미지 파일 선택 트리거
        function triggerFile() {
            document.getElementById("image_file").click();
        }
        function handleFileChange(input) {
            const fileName = input.files[0] ? input.files[0].name : "";
            document.getElementById("fileNameLabel").textContent = fileName || "이미지 업로드";
        }

        // 코스 등록 함수
        function submitCourse() {
            const courseName = document.getElementById("course_name").value;
            const description = document.getElementById("description").value;
            const tagsJson = JSON.stringify(tagList);
            const storeNames = storeList.map(store => store.name);
            const storesJson = JSON.stringify(storeNames);
            const imageInput = document.getElementById("image_file");
            const imageFile = imageInput.files[0];

            if (storeList.length < 3) {
                alert("코스를 등록하려면 최소 3개의 가게를 선택해야 합니다.");
                return;
            }
            
            if (storeList.length > 5) {
                alert("코스에는 최대 5개의 가게만 등록할 수 있습니다.");
                return;
            }
            
            const formData = new FormData();
            formData.append("mode", "insert");
            formData.append("course_name", courseName);
            formData.append("description", description);
            formData.append("tags_json", tagsJson);
            formData.append("stores_json", storesJson);
            if(imageFile) { formData.append("image_file", imageFile); }

            const xhr = new XMLHttpRequest();
            xhr.open("POST", "admin_Course_Register.jsp", true);
            xhr.onreadystatechange = function() {
                if(xhr.readyState === 4 && xhr.status === 200) {
                    if(xhr.responseText.trim() === "success") {
                        alert("맛집 추천 코스 등록이 완료되었습니다.");
                        location.reload();
                    } else {
                        alert("등록에 실패했습니다. 입력값을 확인하세요.");
                    }
                }
            };
            xhr.send(formData);
        }
        
        function displaySearchResults(results) {
            let html = "";
            if(results.length === 0) {
                html = "<p>검색 결과가 없습니다.</p>";
            } else {
                html += "<table class='result-table'><thead><tr><th>가게명</th><th>주소</th><th>선택</th></tr></thead><tbody>";
                results.forEach(item => {
                    html += "<tr>";
                    html += "<td>" + item.rst_name + "</td>";
                    html += "<td>" + item.rst_address + "</td>";
                    html += "<td><a href='javascript:void(0);' onclick=\"addStore(" 
                          + item.rst_id + ", '" + item.rst_name.replace("'", "\\'") + "', " 
                          + item.rst_lat + ", " + item.rst_long + ", '" + item.imgpath + "')\">선택</a></td>";
                    html += "</tr>";
                });
                html += "</tbody></table>";
            }
            document.getElementById("restaurantResults").innerHTML = html;
        }
    </script>
</head>
<body>
    <!-- 사이드바 및 헤더 인클루드 -->
    <%@ include file="../admin_Header.jsp" %>
    
    <div class="main-content">
        <div class="course-register-container">
            <h2>맛집 추천 코스 등록</h2>
            <hr class="divider">
            <div class="input-row">
                <label for="course_name">코스 이름</label>
                <input type="text" id="course_name" required>
            </div>
            <div class="input-row">
                <label for="description">설명</label>
                <textarea id="description" rows="3" required></textarea>
            </div>
            <div class="input-row">
                <label for="image_file">대표 이미지</label>
                <div class="upload-wrapper">
                    <span id="fileNameLabel" class="upload-label">이미지 업로드</span>
                    <button type="button" onclick="triggerFile()">이미지 등록하기</button>
                </div>
                <input type="file" id="image_file" accept="image/*" onchange="handleFileChange(this)">
            </div>
            <div class="input-row">
                <label>태그 포함</label>
                <table class="tag-table">
                    <thead>
                        <tr><th>태그</th><th>삭제</th></tr>
                    </thead>
                    <tbody id="tagTableBody">
                        <!-- 태그 데이터는 JavaScript로 동적 생성 -->
                    </tbody>
                </table>
            </div>
            <div class="input-row">
                <label>🤩음식점 추가하기🤩</label>
                <button type="button" onclick="openRestaurantModal()">가게 선택하기</button>
                <table class="store-table">
                    <thead>
                        <tr><th>가게명</th><th>삭제</th></tr>
                    </thead>
                    <tbody id="storeTableBody">
                        <!-- 선택된 음식점 목록은 JavaScript로 동적 생성 -->
                    </tbody>
                </table>
            </div>
            <button type="button" class="submit-btn" onclick="submitCourse()">등록</button>
        </div>
    </div>
    
    <!-- 맛집 검색 모달 -->
    <div id="restaurantModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeRestaurantModal()">&times;</span>
            <h2>가게 선택</h2>
            <input type="text" id="restaurantSearch" placeholder="맛집 이름 검색 (선택 사항)">
            <button type="button" onclick="searchRestaurant()">검색</button>
            <div id="restaurantSelectMap"></div>
            <div id="restaurantResults"></div>
        </div>
    </div>
</body>
</html>