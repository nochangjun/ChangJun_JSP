<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.MemberMgr, project.MemberBean" %>
<%@ page import="project.SendMail" %>
<%
    request.setCharacterEncoding("UTF-8");

    String username = request.getParameter("username");
    String email = request.getParameter("email");

    MemberMgr mgr = new MemberMgr();
    MemberBean bean = mgr.getMemberByEmail(email);

    if (bean != null && bean.getMember_name().equals(username)) {
        String subject = "[YUMMY JEJU] 아이디 찾기 안내";
        String content = username + "님, 요청하신 아이디는 다음과 같습니다:\n\n" +
                         "👉 아이디: " + bean.getMember_id() + "\n\n" +
                         "감사합니다. YUMMY JEJU 드림.";

        boolean sent = SendMail.send(email, subject, content);

        if (sent) {
            out.println("<script>alert('입력하신 이메일로 아이디를 발송했습니다.'); location.href='login.jsp';</script>");
        } else {
            out.println("<script>alert('메일 전송에 실패했습니다. 관리자에게 문의해주세요.'); history.back();</script>");
        }
    } else {
        out.println("<script>alert('입력하신 정보와 일치하는 회원정보가 없습니다.'); history.back();</script>");
    }
%>
