<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
    System.out.println("로그아웃 전 admin_id: " + session.getAttribute("admin_id"));
    session.invalidate();

    // 쿠키 제거 (id, loginType 삭제)
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie c : cookies) {
            if ("id".equals(c.getName()) || "loginType".equals(c.getName())) {
                c.setMaxAge(0);
                c.setPath("/");
                response.addCookie(c);
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>로그아웃 처리중</title>
</head>
<body>
<script>
    // 클라이언트에서 세션스토리지 originalUrl 제거
    sessionStorage.removeItem('originalUrl');

    // 메인 페이지로 이동
    location.href = "../main.jsp";
</script>
</body>
</html>
