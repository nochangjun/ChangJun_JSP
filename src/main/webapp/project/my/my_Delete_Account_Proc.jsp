<%@ page  contentType="text/html; charset=UTF-8"%>
<%@ page import="project.MemberMgr" %>
<%
    request.setCharacterEncoding("UTF-8");

    String id = (String) session.getAttribute("idKey");
    if (id == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    MemberMgr mgr = new MemberMgr();
    String[] ids = { id };
    mgr.deleteMembers(ids);

    session.invalidate(); // 세션 끊기
%>
<script>
    alert("회원탈퇴가 정상적으로 처리되었습니다.");
    location.href = "../main.jsp"; // 탈퇴 후 이동할 페이지
</script>