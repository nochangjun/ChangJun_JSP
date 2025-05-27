<%@page import="java.io.Console"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="project.MemberMgr, project.MemberBean" %>
<%
	request.setCharacterEncoding("UTF-8");

	String realName     = request.getParameter("realName");
	String email        = request.getParameter("email");
	String nickname     = request.getParameter("nickname");
	String phone        = request.getParameter("phone");
	String profileImage = request.getParameter("profileImage");
	
	// ④ POST로 넘어온 redirect
	String redirectUrl  = request.getParameter("redirect");
	System.out.println("최종 url : "+ redirectUrl);
	if (redirectUrl == null || redirectUrl.trim().isEmpty()) {
	    redirectUrl = "../main.jsp"; 
	}

	String finalNickname = (nickname != null && !nickname.trim().isEmpty())
            ? nickname
            : realName;
	
	MemberMgr mgr = new MemberMgr();
	MemberBean member = mgr.getMemberByEmail(email);

	if (member == null) {
		out.println("DEBUG: inserting new member for " + email + "<br/>");
		MemberBean newMember = new MemberBean();
		newMember.setMember_id(email);
		newMember.setMember_pwd("");
		newMember.setMember_name(realName != null ? realName : email);
		newMember.setMember_phone(phone != null ? phone : phone);
		newMember.setMember_email(email);
		newMember.setMember_nickname(finalNickname);
		newMember.setMember_image(profileImage);
		mgr.insertMember(newMember);
		
		try {
	        mgr.insertMember(newMember);
	    } catch(Exception e) {
	        // 톰캣 로그에 스택트레이스 기록
	        log("insertMember 예외 발생: " + e.getMessage(), e);
	    }
	} else {
        out.println("DEBUG: member already exists, skip insert<br/>");
    }

	session.setAttribute("idKey", email);
	session.setAttribute("loginType", "naver");

	// 로그인 후 이동할 페이지 지정
	if (redirectUrl == null || redirectUrl.equals("")) {
	    redirectUrl = "../main.jsp";
	}
	
	response.sendRedirect(redirectUrl);
%>
