<%@ page import="project.NoticeMgr" %>
<%
    String memberId = (String) session.getAttribute("idKey");
    if (memberId != null) {
        NoticeMgr mgr = new NoticeMgr();
        mgr.markAllNoticesAsRead(memberId);
        response.setStatus(200); // OK
    } else {
        response.setStatus(401); // Unauthorized
    }
%>
