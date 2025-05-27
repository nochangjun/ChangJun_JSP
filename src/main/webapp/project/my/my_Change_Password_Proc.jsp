<%@ page  contentType="text/html; charset=UTF-8"%>
<%@ page import="project.MemberMgr" %>
<%
    request.setCharacterEncoding("UTF-8");

    String id = (String) session.getAttribute("idKey");
    String currentPw = request.getParameter("currentPassword");
    String newPw = request.getParameter("newPassword");

    if (id == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    MemberMgr mgr = new MemberMgr();

    if (mgr.checkPassword(id, currentPw)) {
        boolean success = mgr.updatePassword(id, newPw);
        if (success) {
%>
    <script>
        alert("비밀번호가 성공적으로 변경되었습니다.");
        location.href = "my_Change_Password.jsp";
    </script>
<%
        } else {
%>
    <script>
        alert("비밀번호 변경에 실패했습니다.");
        history.back();
    </script>
<%
        }
    } else {
%>
    <script>
        alert("현재 비밀번호가 일치하지 않습니다.");
        history.back();
    </script>
<%
    }
%>
