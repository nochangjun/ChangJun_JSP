<%-- <%@page import="PRACTICE.RestaurantBean"%>
<%@page import="java.util.Vector"%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="PRACTICE.TouristApiService, com.google.gson.JsonArray, com.google.gson.JsonObject" %>
<jsp:useBean id="mgr" class="PRACTICE.RestaurantMgr"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>제주 관광 정보</title>
    <style>
        body { font-family: Arial, sans-serif; }
        .container { width: 80%; margin: 0 auto; }
        .tourist-item { border: 1px solid #ddd; padding: 10px; margin: 10px 0; }
        img { max-width: 200px; display: block; margin-top: 10px; }
        .pagination { margin-top: 20px; }
        .pagination a { margin: 0 5px; text-decoration: none; }
        .pagination a.active { font-weight: bold; }
    </style>
</head>
<body>
<%
		for(int i=1;i<22;i++){
%>
	<a href="tourist.jsp?page=<%=i%>"><%=i%></a>&nbsp;
<% }%>			
    <div class="container">
        <h2>📌 제주 관광 정보</h2>

<%
    // 페이지 번호를 URL 파라미터에서 받음
    int currentPage = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        currentPage = Integer.parseInt(pageParam);
    }

    // TouristDataResponse 객체를 받음 (response 이름을 변경하여 중복 피하기)
    TouristApiService.TouristDataResponse touristDataResponse = TouristApiService.getTouristData(currentPage);
    
    // touristDataResponse 객체에서 items 배열 추출
    JsonArray touristSpots = touristDataResponse != null ? touristDataResponse.items : null;
    
    int totalRestaurants = 0; // ✅ 음식점 개수 카운트
    Vector<RestaurantBean> vlist = new Vector<RestaurantBean>();
    if (touristSpots != null) {
        for (int i = 0; i < touristSpots.size(); i++) {
            JsonObject item = touristSpots.get(i).getAsJsonObject();

            // ✅ 콘텐츠 코드 정보 (contentscd)
            String contentsValue = "정보 없음";
            String contentsLabel = "정보 없음";
            String contentsRefId = "정보 없음";
            
            if (item.has("contentscd") && !item.get("contentscd").isJsonNull()) {
                JsonObject contentscd = item.getAsJsonObject("contentscd");
                contentsValue = (contentscd.has("value") && !contentscd.get("value").isJsonNull()) 
                                ? contentscd.get("value").getAsString() 
                                : "정보 없음";
                contentsLabel = (contentscd.has("label") && !contentscd.get("label").isJsonNull()) 
                                ? contentscd.get("label").getAsString() 
                                : "정보 없음";
                contentsRefId = (contentscd.has("refId") && !contentscd.get("refId").isJsonNull()) 
                                ? contentscd.get("refId").getAsString() 
                                : "정보 없음";
            }
            
            // ✅ 음식점만 필터링
            if (!"음식점".equals(contentsLabel)) {
                continue; // 음식점이 아니면 다음 항목으로 건너뜀
            } 
            
            totalRestaurants++; // ✅ 음식점 개수 증가

            // ✅ 기본 정보 가져오기
            String title = (item.has("title") && !item.get("title").isJsonNull()) 
                            ? item.get("title").getAsString() 
                            : "제목 없음";

            String address = (item.has("address") && !item.get("address").isJsonNull()) 
                            ? item.get("address").getAsString() 
                            : "주소 정보 없음";

            String roadaddress = (item.has("roadaddress") && !item.get("roadaddress").isJsonNull()) 
                            ? item.get("roadaddress").getAsString() 
                            : "주소 정보 없음";

            String introduction = (item.has("introduction") && !item.get("introduction").isJsonNull()) 
                    ? item.get("introduction").getAsString() 
                    : "정보 없음";

            double latitude = (item.has("latitude") && !item.get("latitude").isJsonNull()) 
                            ? item.get("latitude").getAsDouble() 
                            : 0.0;

            double longitude = (item.has("longitude") && !item.get("longitude").isJsonNull()) 
                            ? item.get("longitude").getAsDouble() 
                            : 0.0;

            String phoneno = (item.has("phoneno") && !item.get("phoneno").isJsonNull()) 
                    ? item.get("phoneno").getAsString() 
                    : "정보 없음";

            // ✅ 관련 태그 전체 가져오기
            String alltag = (item.has("alltag") && !item.get("alltag").isJsonNull()) 
                    ? item.get("alltag").getAsString() 
                    : "태그 정보 없음";

            // ✅ 콘텐츠 ID 가져오기
            String contentsid = (item.has("contentsid") && !item.get("contentsid").isJsonNull()) 
                    ? item.get("contentsid").getAsString() 
                    : "콘텐츠 ID 없음";

            // ✅ region1cd (value, label) 가져오기
            String regionValue = "정보 없음";
            String regionLabel = "정보 없음";
            if (item.has("region1cd") && !item.get("region1cd").isJsonNull()) {
                JsonObject regionObj = item.getAsJsonObject("region1cd");
                regionValue = (regionObj.has("value") && !regionObj.get("value").isJsonNull()) 
                                ? regionObj.get("value").getAsString() 
                                : "정보 없음";
                regionLabel = (regionObj.has("label") && !regionObj.get("label").isJsonNull()) 
                                ? regionObj.get("label").getAsString() 
                                : "정보 없음";
            }
            
            // ✅ region2cd (value, label) 가져오기
            String region2Label = "정보 없음";
            if (item.has("region2cd") && !item.get("region2cd").isJsonNull()) {
                JsonObject regionObj = item.getAsJsonObject("region2cd");
                region2Label = (regionObj.has("label") && !regionObj.get("label").isJsonNull()) 
                                ? regionObj.get("label").getAsString() 
                                : "정보 없음";
            }

            // ✅ repPhoto에서 photoid, imgpath, thumbnailpath 가져오기
            String photoid = "이미지 없음";
            String imgpath = "";
            String thumbnailpath = "";
            String descseo = "정보 없음";
            
            if (item.has("repPhoto") && !item.get("repPhoto").isJsonNull()) {
                JsonObject repPhoto = item.getAsJsonObject("repPhoto");
                
                // ✅ descseo 가져오기 (repPhoto 바로 아래에 있음)
                if (repPhoto.has("descseo") && !repPhoto.get("descseo").isJsonNull()) {
                    descseo = repPhoto.get("descseo").getAsString();
                }
                
                if (repPhoto.has("photoid") && !repPhoto.get("photoid").isJsonNull()) {
                    JsonObject photoObj = repPhoto.getAsJsonObject("photoid");
                    if (photoObj.has("photoid") && !photoObj.get("photoid").isJsonNull()) {
                        photoid = photoObj.get("photoid").getAsString();
                    }
                    if (photoObj.has("imgpath") && !photoObj.get("imgpath").isJsonNull()) {
                        imgpath = photoObj.get("imgpath").getAsString();
                    }
                    if (photoObj.has("thumbnailpath") && !photoObj.get("thumbnailpath").isJsonNull()) {
                        thumbnailpath = photoObj.get("thumbnailpath").getAsString();
                    }
                }
            }
%>
            <div class="tourist-item">
                <h3><%= title %></h3>
                <p><strong>주소:</strong> <%= address %></p>
                <p><strong>도로명주소:</strong> <%= roadaddress %></p>
                <p><strong>소개:</strong> <%= introduction %></p>
                <p><strong>위도:</strong> <%= latitude %>, <strong>경도:</strong> <%= longitude %></p>
                <p><strong>전화번호:</strong> <%= phoneno %></p>
                <p><strong>관련 태그 전체:</strong> <%= alltag %></p>
                <p><strong>콘텐츠 ID:</strong> <%= contentsid %></p>
                <p><strong>콘텐츠 코드 값:</strong> <%= contentsValue %></p>
                <p><strong>콘텐츠 코드 라벨:</strong> <%= contentsLabel %></p>
                <p><strong>콘텐츠 코드 ReferenceID:</strong> <%= contentsRefId %></p>
                <p><strong>지역 코드 (value):</strong> <%= regionValue %></p>
                <p><strong>지역 라벨 (label):</strong> <%= regionLabel %></p>
                <p><strong>검색엔진최적화 키워드:</strong> <%= descseo %></p>
                <p><strong>Photo ID:</strong> <%= photoid %></p>

                <% if (!thumbnailpath.isEmpty()) { %>
                    <p><strong>썸네일 이미지:</strong></p>
                    <img src="<%= thumbnailpath %>" alt="Thumbnail Image">
                <% } %>

                <% if (!imgpath.isEmpty()) { %>
                    <p><strong>대표 이미지:</strong></p>
                    <img src="<%= imgpath %>" alt="Tourist Spot Image">
                <% } %>
            </div>
<%
			RestaurantBean bean = new RestaurantBean();
			bean.setTitle(title);
			bean.setRoadaddress(roadaddress);
			bean.setIntroduction(introduction);
			bean.setLatitude(latitude);
			bean.setLongitude(longitude);
			bean.setPhoneno(phoneno);
			bean.setAlltag(alltag);
			bean.setRegionLabel(regionLabel);
			bean.setRegion2Label(region2Label);
			bean.setThumbnailpath(thumbnailpath.getBytes());
			bean.setImgpath(imgpath.getBytes());
			vlist.addElement(bean);
        }
        mgr.insertRestaurant(vlist);
    } else {
%>
        <p>데이터를 불러올 수 없습니다.</p>
<%
    }

    // ✅ 음식점이 하나도 없을 경우 메시지 표시
    if (totalRestaurants == 0) {
%>
        <p>음식점 데이터가 없습니다.</p>
<%
    } else {
%>
        <p><strong>총 음식점 수:</strong> <%= totalRestaurants %> 개</p>
<%
    }

    // 페이지네이션: 총 페이지 수가 1 이상일 때 페이지 링크를 표시
    if (touristDataResponse != null && touristDataResponse.pageCount > 1) {
%>
    <div class="pagination">
        <% for (int i = 1; i <= touristDataResponse.pageCount; i++) { %>
            <a href="?page=<%= i %>" class="<%= (i == currentPage) ? "active" : "" %>">Page <%= i %></a>
        <% } %>
    </div>
<%
    }
%>
    </div>
</body>
</html> --%>