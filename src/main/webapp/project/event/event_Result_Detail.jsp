<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.EvtParticipantsMgr, project.EvtParticipantsBean" %>
<%
    request.setCharacterEncoding("UTF-8");

    String idStr = request.getParameter("id");
    if (idStr == null) {
        response.sendRedirect("event_Result.jsp");
        return;
    }

    int evt_id = Integer.parseInt(idStr);
    EvtParticipantsMgr mgr = new EvtParticipantsMgr();
    EvtParticipantsBean bean = mgr.getEventById(evt_id);

    if (bean == null) {
        response.sendRedirect("event_Result.jsp");
        return;
    }
    
    // 컨텐츠 줄바꿈 처리
    String formattedContent = "";
    if (bean.getEvt_content() != null) {
        formattedContent = bean.getEvt_content().replaceAll("\n", "<br>");
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>당첨자 발표 상세 | YUMMY JEJU</title>
    <link rel="stylesheet" href="../css/header.css">
    <link rel="stylesheet" href="../css/footer.css">
    <link rel="stylesheet" href="../css/event_Result_Detail.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
</head>
<body>
    <!-- 헤더 인클루드 -->
    <jsp:include page="../header.jsp" />

    <div class="event-container">
        <h1 class="event-title">이벤트</h1>

        <div class="event-tabs">
            <a href="event.jsp" class="tab">이벤트 참여</a>
            <a href="event_Result.jsp" class="tab active">당첨자 발표</a>
        </div>

        <!-- 당첨자 발표 상세 내용 -->
        <div class="event-detail-container">
            <div class="event-detail-header">
                <div class="event-detail-title"><%= bean.getEvt_title() %></div>
                <div class="event-detail-date">발표일: <%= bean.getEvt_created_at().substring(0, 10) %></div>
            </div>

            <div class="event-detail-content">
                <%= formattedContent %>
                
                <% if(bean.getEvt_content() != null && bean.getEvt_content().contains("당첨자")) { %>
                <div class="event-winners">
                    <h3>🎉 당첨을 축하합니다! 🎉</h3>
                    <div class="winner-list">
                        <!-- 당첨자 목록은 콘텐츠에 포함되어 있음 -->
                    </div>
                </div>
                <% } %>
            </div>

            <div class="event-detail-buttons">
                <a href="event_Result.jsp" class="back-button">목록</a>
            </div>
        </div>
    </div>

    <!-- 푸터 인클루드 -->
    <jsp:include page="../footer.jsp" />
</body>
</html>