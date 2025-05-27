<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Random" %>
<%@ page import="java.util.Arrays" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>랜덤 음식 추천 기계</title>
    <style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: 'Noto Sans KR', sans-serif;
    }

    body {
        background-color: #f8f8f8;
        min-height: 100vh;
        display: flex;
        flex-direction: column;
    }
    
    main {
        flex: 1;
        display: flex;
        justify-content: center;
        align-items: center;
        background-color: #f8f8f8;
    }

    .container {
        width: 100%;
        max-width: 400px;
        text-align: center;
        padding: 20px;
          margin-top: 100px;
          margin-bottom: 100px;
          background-color: #f8f8f8;
    }

    .title {
        color: #c4b998;
        margin-bottom: 60px;
        font-size: 2.2rem;
        font-weight: bold;
        margin-bottom: 100px;
    }

    /* 캡슐 디자인 */
    .capsule-container {
        position: relative;
        width: 300px;
        height: 300px;
        margin: 0 auto 40px;
    }

    .capsule-top {
        position: absolute;
        width: 240px;
        height: 120px;
        background-color: #ffe6e8;
        border-radius: 120px 120px 0 0;
        top: 0;
        left: 50%;
        transform: translateX(-50%);
        z-index: 3;
        transition: transform 0.5s ease-in-out;
    }
    
    .capsule-top.open {
        transform: translateX(-50%) translateY(-100px) rotate(-20deg);
        
    }

    .capsule-bottom {
        position: absolute;
        width: 240px;
        height: 120px;
        background-color: #ffd1d6;
        border-radius: 0 0 120px 120px;
        bottom: 60px;
        left: 50%;
        transform: translateX(-50%);
        z-index: 1;
        display: flex;
        justify-content: center;
        align-items: center;
        
    }

    .result {
        font-size: 2rem;
        color: #6e4c4f;
        font-weight: bold;
    }

    /* 버튼 디자인 */
    .button-container {
        display: flex;
        justify-content: center;
        flex-wrap: wrap;
        gap: 20px;
        margin-top: 20px;
    }

    .btn {
        padding: 10px 30px;
        border-radius: 50px;
        background-color: #ffd1d6;
        color: #6e4c4f;
        border: 2px solid #6e4c4f;
        font-size: 1.1rem;
        font-weight: bold;
        cursor: pointer;
        transition: all 0.3s;
    }

    .btn:hover {
        background-color: #6e4c4f;
        color: #ffd1d6;
    }

    .refresh-btn {
        margin-top: 10px;
    }
    </style>
    <script>
    function openCapsule() {
        document.querySelector('.capsule-top').classList.add('open');
    }
    
    function closeCapsule() {
        document.querySelector('.capsule-top').classList.remove('open');
    }
    
    window.onload = function() {
        <% if (request.getParameter("generate") != null) { %>
            openCapsule();
        <% } %>
        
        <% if (request.getParameter("reset") != null) { %>
            closeCapsule();
        <% } %>
    }
    </script>
</head>
<body>
    <%-- header.jsp 포함 --%>
    <jsp:include page="../header.jsp" />
    
    <main>
    <div class="container">
        <h1 class="title">오늘 뭐 먹지?</h1>
        
        <div class="capsule-container">
            <div class="capsule-top" <% if (request.getParameter("reset") != null) { %>class=""<% } else if (request.getParameter("generate") != null) { %>class="open"<% } %>></div>
            <div class="capsule-bottom">
                <%
                    // 음식 목록 배열
                    String[] foods = {
                        "아구찜", "된장찌개", "비빔밥", "불고기", "삼겹살", 
                        "짜장면", "짬뽕", "탕수육", "치킨", "피자", 
                        "파스타", "스테이크", "초밥", "라멘", "햄버거", 
                        "샐러드", "카레", "국수", "떡볶이", "김밥"
                    };
                    
                    // 결과를 저장할 변수
                    String randomFood = null;
                    
                    // 폼이 제출되었는지 확인
                    if (request.getParameter("generate") != null) {
                        Random random = new Random();
                        int randomIndex = random.nextInt(foods.length);
                        randomFood = foods[randomIndex];
                    }
                    
                    // 초기화 버튼이 눌렸는지 확인
                    boolean isReset = request.getParameter("reset") != null;
                    
                    // 결과가 있으면 표시
                    if (randomFood != null && !isReset) {
                %>
                <div class="result"><%= randomFood %></div>
                <% } else { %>
                <div class="result">전체</div>
                <% } %>
            </div>
        </div>
        
        <div class="button-container">
            <form method="post" action="event_Recommendation.jsp">
                <button type="submit" name="generate" class="btn" onclick="openCapsule()">다시 뽑기</button>
            </form>
            <form method="post" action="event_Recommendation.jsp">
                <button type="submit" name="reset" class="btn" onclick="closeCapsule()">초기화</button>
            </form>
        </div>
    </div>
    </main>
    
    <%-- footer.jsp 포함 --%>
    <jsp:include page="../footer.jsp" />
</body>
</html>