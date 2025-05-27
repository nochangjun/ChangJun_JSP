<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.MemberBean, project.MemberMgr, project.NoticeMgr, project.NoticeBean" %>

<%
    // 자동 로그인용 쿠키에서 세션 복원
    if (session.getAttribute("idKey") == null) {
        Cookie[] cookies = request.getCookies();
        String cookieId = null;
        String cookieType = null;

        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("id".equals(c.getName())) {
                    cookieId = c.getValue();
                } else if ("loginType".equals(c.getName())) {
                    cookieType = c.getValue();
                }
            }
        }

        if (cookieId != null && "normal".equals(cookieType)) {
            session.setAttribute("idKey", cookieId);
            session.setAttribute("loginType", "normal");
        }
    }

    String id = (String) session.getAttribute("idKey");
    String loginType = (String) session.getAttribute("loginType");
    
    // 닉네임 - 매 요청마다 DB에서 최신 정보를 조회하도록 수정
    String nickname = null;
    if (id != null) {
        MemberMgr memberMgr = new MemberMgr();
        MemberBean memberBean = memberMgr.getMember(id);
        if (memberBean != null) {
            nickname = memberBean.getMember_nickname();
            // 항상 세션을 최신 정보로 업데이트
            session.setAttribute("memberNickname", nickname);
        }
    }
    
    // 닉네임이 없으면 아이디 사용
    if (nickname == null || nickname.trim().isEmpty()) {
        nickname = id;
    }
    
    boolean hasNewNotice = false;
    if (id != null) {
        NoticeMgr noticeMgr = new NoticeMgr();
        hasNewNotice = noticeMgr.hasNewNotice(id);
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>YUMMY JEJU Header</title>
    <style>
        /* 헤더 스타일 스코프를 위한 리셋 */
        .yummy-header-container * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
        }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/project/css/header.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <script>
        const isLoggedIn = <%=(session.getAttribute("idKey") != null) ? "true" : "false"%>;
        const userId = "<%= session.getAttribute("idKey") != null ? session.getAttribute("idKey") : "guest" %>";
        sessionStorage.setItem("userId", userId);
    </script>
</head>
<body>
    <header class="yummy-header-container">
        <div class="yummy-header-inner">
            <!-- 왼쪽 로고 -->
            <div class="yummy-header-left">
                <a href="<%=request.getContextPath()%>/project/main.jsp">
                    <h1 class="yummy-logo">YUMMY JEJU</h1>
                </a>
            </div>

            <!-- 중앙 항목 -->
            <nav class="yummy-header-center">
                <ul class="yummy-menu-list">
                    <li class="yummy-menu-item">
                        <a href="${pageContext.request.contextPath}/project/food/food_Representative.jsp">음식</a>
                        <ul class="yummy-sub">
                            <li><a href="${pageContext.request.contextPath}/project/food/food_Representative.jsp">대표음식</a></li>
                        </ul>
                    </li>
                    <li class="yummy-menu-item">
                        <a href="${pageContext.request.contextPath}/project/rst/rst_Find.jsp">맛집</a>
                        <ul class="yummy-sub">
                            <li><a href="${pageContext.request.contextPath}/project/rst/rst_Find.jsp">맛집 찾기</a></li>
                            <li><a href="${pageContext.request.contextPath}/project/rst/rst_Course_List.jsp">하루 맛집 코스</a></li>
                        </ul>
                    </li>
                    <li class="yummy-menu-item">
                        <a href="${pageContext.request.contextPath}/project/event/event.jsp">이벤트</a>
                        <ul class="yummy-sub">
                            <li><a href="${pageContext.request.contextPath}/project/event/event.jsp">맛집 이벤트</a></li>
                            <li><a href="${pageContext.request.contextPath}/project/event/event_Recommendation.jsp">음식추천</a></li>
                        </ul>
                    </li>
                    <li class="yummy-menu-item">
                        <a href="${pageContext.request.contextPath}/project/my/my_Page.jsp" data-login-required="true">나의 맛집</a>
                        <ul class="yummy-sub">
                            <li><a href="${pageContext.request.contextPath}/project/my/my_Page.jsp" data-login-required="true">마이 페이지</a></li>
                            <li><a href="javascript:void(0);" onclick="goToMyProfile()">정보 수정</a></li>
                        </ul>
                    </li>
                    <li class="yummy-menu-item">
                        <a href="${pageContext.request.contextPath}/project/support/support_Board.jsp">고객지원</a>
                        <ul class="yummy-sub">
                            <li><a href="${pageContext.request.contextPath}/project/support/support_Board.jsp">게시판</a></li>
                            <li><a href="${pageContext.request.contextPath}/project/support/support_Inquiry.jsp">문의하기</a></li>
                        </ul>
                    </li>
                </ul>
            </nav>

            <!-- 오른쪽 아이콘 및 버튼 -->
            <div class="yummy-header-right">
                <%
                if (id != null && loginType != null && (loginType.equals("normal") || loginType.equals("naver"))) {
                %>
                <span class="yummy-welcome-message">
                    <i class="fas fa-user" style="margin-right: 5px;"></i>환영합니다, <strong><%=nickname%></strong>님
                </span>
                <form action="<%=request.getContextPath()%>/project/login/logout_Proc.jsp" method="post" style="display: inline;">
                    <button type="submit" class="yummy-header-btn yummy-loginout-btn">로그아웃</button>
                </form>
                <%
                } else {
                %>
                <a href="javascript:void(0);" onclick="goToLoginWithRedirect();">
                    <button class="yummy-header-btn yummy-loginout-btn">
                        <i class="fas fa-sign-in-alt" style="margin-right: 5px;"></i>로그인
                    </button>
                </a>
                <%
                }
                %>
                <button class="yummy-header-icon yummy-search-icon" onclick="openSearchPopup()" title="검색">
                    <img src="${pageContext.request.contextPath}/project/img/돋보기.png" alt="검색" />
                </button>
                <button class="yummy-header-icon yummy-notify-icon" onclick="openNoticePopup()" title="알림" style="position: relative;">
                    <img src="${pageContext.request.contextPath}/project/img/알림.png" alt="알림" />
                    <% if (hasNewNotice) { %>
				        <span class="notice-dot" id="noticeDot"></span>
				    <% } %>
                </button>
            </div>
        </div>
        
        <!-- 통합 서브메뉴 컨테이너 -->
        <div class="yummy-submenu-container">
            <div class="yummy-submenu-inner">
                <!-- 음식 -->
                <div class="yummy-submenu-column">
                    <h3 class="yummy-submenu-title">음식</h3>
                    <ul class="yummy-submenu-list">
                        <li class="yummy-submenu-item"><a href="${pageContext.request.contextPath}/project/food/food_Representative.jsp">대표음식</a></li>
                    </ul>
                </div>
                
                <!-- 맛집 -->
                <div class="yummy-submenu-column">
                    <h3 class="yummy-submenu-title">맛집</h3>
                    <ul class="yummy-submenu-list">
                        <li class="yummy-submenu-item"><a href="${pageContext.request.contextPath}/project/rst/rst_Find.jsp">맛집 찾기</a></li>
                        <li class="yummy-submenu-item"><a href="${pageContext.request.contextPath}/project/rst/rst_Course_List.jsp">하루 맛집 코스</a></li>
                    </ul>
                </div>
                
                <!-- 이벤트 -->
                <div class="yummy-submenu-column">
                    <h3 class="yummy-submenu-title">이벤트</h3>
                    <ul class="yummy-submenu-list">
                        <li class="yummy-submenu-item"><a href="${pageContext.request.contextPath}/project/event/event.jsp">맛집 이벤트</a></li>
                        <li class="yummy-submenu-item"><a href="${pageContext.request.contextPath}/project/event/event_Recommendation.jsp">음식추천</a></li>
                    </ul>
                </div>
                
                <!-- 나의 맛집 -->
                <div class="yummy-submenu-column">
                    <h3 class="yummy-submenu-title">나의 맛집</h3>
                    <ul class="yummy-submenu-list">
                        <li class="yummy-submenu-item"><a href="${pageContext.request.contextPath}/project/my/my_Page.jsp" data-login-required="true">마이 페이지</a></li>
                        <li class="yummy-submenu-item"><a href="javascript:void(0);" onclick="goToMyProfile()">정보 수정</a></li>
                    </ul>
                </div>
                
                <!-- 고객지원 -->
                <div class="yummy-submenu-column">
                    <h3 class="yummy-submenu-title">고객지원</h3>
                    <ul class="yummy-submenu-list">
                        <li class="yummy-submenu-item"><a href="${pageContext.request.contextPath}/project/support/support_Board.jsp">게시판</a></li>
                        <li class="yummy-submenu-item"><a href="${pageContext.request.contextPath}/project/support/support_Inquiry.jsp">문의하기</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </header>

    <jsp:include page="/project/search_Popup.jsp" />
    <jsp:include page="/project/notice_Popup.jsp" />

    <script>
        // 로그인 페이지로 이동
        function goToLogin() {
            window.location.href = "<%=request.getContextPath()%>/project/login/login.jsp";
        }

        // 로그인 경고 모달 닫기
        function closeLoginModal() {
            document.getElementById("yummy-loginAlertModal").style.display = "none";
        }

        // 프로필 페이지로 이동
        function goToMyProfile() {
            const loginType = <%=session.getAttribute("loginType") == null ? "null" : "\"" + session.getAttribute("loginType") + "\"" %>;
            
            if (loginType === null) {
                // 로그인 안 되어 있으면 모달 띄우기
                document.getElementById("yummy-loginAlertModal").style.display = "flex";
                return;
            }
            
            if (loginType === "normal") {
                location.href = "<%=request.getContextPath()%>/project/my/my_Chk.jsp";
            } else if (loginType === "naver") {
                location.href = "<%=request.getContextPath()%>/project/my/my_Update_Profile_Naver.jsp";
            } else {
                // 예외적인 로그인 타입(예: 관리자 또는 미래 확장)을 위한 처리
                alert("접근 권한이 없습니다.");
            }
        }

        // 로그인 필요한 링크 처리
        document.addEventListener('DOMContentLoaded', function() {
            const loginRequiredLinks = document.querySelectorAll('a[data-login-required="true"]');
            loginRequiredLinks.forEach(link => {
                link.addEventListener('click', function(e) {
                    if (!isLoggedIn) {
                        e.preventDefault();
                        document.getElementById("yummy-loginAlertModal").style.display = "flex";
                    }
                });
            });
        });
    </script>

	<script>
        function goToLoginWithRedirect() {
            const currentURL = window.location.pathname + window.location.search;
            const encodedURL = encodeURIComponent(currentURL);
            const contextPath = "<%= request.getContextPath() %>";
            location.href = "<%= request.getContextPath() %>/project/login/login.jsp?url=" + encodeURIComponent(window.location.pathname + window.location.search);
        }
    </script>
    
    <!-- 로그인 필요 알림 모달 -->
    <div id="yummy-loginAlertModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.5); z-index: 9999; justify-content: center; align-items: center;">
        <div style="background: white; padding: 25px; border-radius: 12px; text-align: center; min-width: 300px;">
            <i class="fas fa-exclamation-circle" style="font-size: 40px; color: #FF8A3D; margin-bottom: 15px;"></i>
            <p style="font-size: 16px; margin-bottom: 20px;">로그인이 필요한 서비스입니다.</p>
            <button onclick="goToLogin()" style="margin-right: 10px; padding: 10px 18px;">로그인하러 가기</button>
            <button onclick="closeLoginModal()" style="padding: 10px 18px;">닫기</button>
        </div>
    </div>

    <!-- 검색 관련 JS 파일 로드 -->
    <script src="${pageContext.request.contextPath}/project/js/search_Popup.js"></script>
</body>
</html>