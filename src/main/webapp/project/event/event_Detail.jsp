<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.EventMgr, project.EventBean" %>
<%@ page import="java.time.LocalDate" %>

<%
    String idParam = request.getParameter("event_id");
    if (idParam == null || idParam.trim().isEmpty()) {
        out.println("<p>이벤트 ID가 없습니다.</p>");
        return;
    }

    int eventId = Integer.parseInt(idParam);

    EventMgr mgr = new EventMgr();
    EventBean bean = mgr.getEventById(eventId);

    // 값이 없을 경우 방어 처리
    if (bean.getTitle() == null) {
        out.println("<p>해당 이벤트를 찾을 수 없습니다.</p>");
        return;
    }

    // ✅ 조회수 증가
    mgr.increaseViews(eventId);

    // ✅ 동적 상태 계산
    String dynamicStatus = "정보 없음";
    String statusClass = "";
    try {
        String startStr = bean.getStartDate();
        String endStr = bean.getEndDate();

        if (startStr != null && endStr != null) {
            LocalDate today = LocalDate.now();
            LocalDate start = LocalDate.parse(startStr);
            LocalDate end = LocalDate.parse(endStr);

            if (today.isBefore(start)) {
                dynamicStatus = "예정";
                statusClass = "upcoming";
            } else if (!today.isAfter(end)) {
                dynamicStatus = "진행중";
                statusClass = "ongoing";
            } else {
                dynamicStatus = "종료";
                statusClass = "ended";
            } 
        }
    } catch (Exception e) {
        dynamicStatus = "날짜 정보 오류";
    }

    // ✅ 이미지 경로 처리
    String imageUrl = bean.getImageUrl();
    boolean isExternal = imageUrl != null && (imageUrl.startsWith("http://") || imageUrl.startsWith("https://"));
    String imagePath = (imageUrl != null && !imageUrl.trim().isEmpty())
        ? (isExternal ? imageUrl : request.getContextPath() + "/" + imageUrl)
        : request.getContextPath() + "/img/default_event.png";

    // ✅ 상태 일괄 업데이트 (옵션)
    mgr.updateEventStatuses();
    
    // ✅ 컨텐츠 줄바꿈 처리
    String formattedContent = "";
    if (bean.getContent() != null) {
        formattedContent = bean.getContent().replaceAll("\n", "<br>");
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>이벤트 상세보기 | YUMMY JEJU</title>
    <link rel="stylesheet" href="../css/header.css">
    <link rel="stylesheet" href="../css/footer.css">
    <link rel="stylesheet" href="../css/event_Detail.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
</head>
<body>
<jsp:include page="../header.jsp" />

<div class="event-detail-container">
    <h1 class="event-main-title">이벤트</h1>

    <div class="event-tabs">
        <a href="event.jsp" class="tab active">이벤트 참여</a>
        <a href="event_Result.jsp" class="tab">당첨자 발표</a>
    </div>

    <div class="event-header">
        <div class="event-tag <%= statusClass %>"><%= dynamicStatus %></div>
        <h1 class="event-title"><%= bean.getTitle() %></h1>

        <div class="event-info">
            <div class="profile-container">
                <div class="profile-image"></div>
                <div class="event-author">관리자 (<%= bean.getAdminId() %>)</div>
            </div>
            <div class="event-date"><%= bean.getStartDate() %> ~ <%= bean.getEndDate() %></div>
            <div class="event-views">조회 <%= bean.getViews() %></div>
        </div>
        
            <div class="event-content">
        <img src="<%= imagePath %>" alt="이벤트 이미지">
        <div class="event-description">
            <p><%= formattedContent %></p>
        </div>
    </div>
    </div>



    <div class="list-button-container">
        <a href="event.jsp" class="list-button">목록</a>
    </div>
</div>

<jsp:include page="../footer.jsp" />
</body>
</html>