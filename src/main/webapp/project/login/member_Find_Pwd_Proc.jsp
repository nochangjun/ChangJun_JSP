<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.MemberMgr, project.MemberBean" %>
<%@ page import="project.SendMail" %>
<%
    request.setCharacterEncoding("UTF-8");
    String userid = request.getParameter("userid");
    String email = request.getParameter("email");

    MemberMgr mgr = new MemberMgr();
    MemberBean bean = mgr.getMember(userid);

    if(bean != null && bean.getMember_email().equals(email)) {
        // 1. 임시 비밀번호 생성
        String tempPwd = java.util.UUID.randomUUID().toString().substring(0, 8); // 예: 8자리 임시 비번

        // 2. DB에 업데이트 (선택적으로 암호화 가능)
        mgr.updateMemberPassword(userid, tempPwd); // 이 메서드 구현 필요

        // 3. 이메일 전송
        String subject = "[YUMMY JEJU] 임시 비밀번호 안내";
        String content = bean.getMember_name() + "님,\n\n요청하신 임시 비밀번호는 아래와 같습니다:\n\n" +
                         "👉 " + tempPwd + "\n\n" +
                         "로그인 후 꼭 비밀번호를 변경해주세요.";

        boolean sent = SendMail.send(email, subject, content);

        if(sent){
            out.println("<script>alert('임시 비밀번호를 이메일로 발송했습니다.'); location.href='login.jsp';</script>");
        } else {
            out.println("<script>alert('메일 전송에 실패했습니다.'); history.back();</script>");
        }

    } else {
        out.println("<script>alert('입력하신 정보와 일치하는 회원정보가 없습니다.'); history.back();</script>");
    }
%>
