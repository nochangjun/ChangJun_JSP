<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.Cookie, java.net.URLEncoder, java.net.URLDecoder, project.*" %>

<%
	response.setContentType("application/json; charset=UTF-8");
    String memberId = (String) session.getAttribute("idKey");

	if (memberId == null) {
	    out.print("{\"error\": \"로그인이 필요합니다.\"}");
	    return;
	}
	
    int commentId = Integer.parseInt(request.getParameter("commentId"));
    boolean liked = false;
    int likeCount = 0;

 	// memberId 인코딩 처리
    String encodedMemberId = URLEncoder.encode(memberId, "UTF-8");
    
    HashSet<String> likedComments = (HashSet<String>) application.getAttribute("likedComments");
    if (likedComments == null) {
        likedComments = new HashSet<>();
        application.setAttribute("likedComments", likedComments);
    }

    String likeKey = encodedMemberId + "_comment_" + commentId;
    CommentMgr mgr = new CommentMgr();
    CommentBean comment = mgr.getComment(commentId);
    likeCount = comment.getComment_like();

    if (likedComments.contains(likeKey)) {
        // 💔 좋아요 취소
        mgr.decrementLike(commentId);
        likeCount = Math.max(0, likeCount - 1);
        likedComments.remove(likeKey);
        liked = false;

        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("liked_comment_" + commentId + "_" + encodedMemberId)) {
                    cookie.setMaxAge(0);
                    cookie.setPath("/");
                    response.addCookie(cookie);
                    break;
                }
            }
        }
    } else {
        // ❤️ 좋아요 추가
        mgr.incrementLike(commentId);
        likeCount += 1;
        likedComments.add(likeKey);
        liked = true;

        Cookie cookie = new Cookie("liked_comment_" + commentId + "_" + encodedMemberId, "true");
        cookie.setMaxAge(60 * 60 * 24 * 365);
        cookie.setPath("/");
        response.addCookie(cookie);
    }

    out.print("{\"liked\": " + liked + ", \"likeCount\": " + likeCount + "}");
%>
