<%@ page  contentType="text/html; charset=UTF-8"%>
<%@ page import="project.MemberMgr" %>
<%
    String id = (String) session.getAttribute("idKey");
    String inputPw = request.getParameter("password");

    MemberMgr mgr = new MemberMgr();
    boolean isValid = mgr.loginMember(id, inputPw);

    if (isValid) {
        session.setAttribute("verified", true); // 인증 성공
        response.sendRedirect("my_Update_Profile.jsp");
%>
	<script>
		alert("✅ 인증에 성공했습니다.");
		location.href = "my_Update_Profile.jsp";
	</script>
<%
    } else {
%>
	<script>
		alert("❌ 비밀번호가 일치하지 않습니다.");
		history.back();
	</script>
<%
    }
%>