package project;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import org.json.JSONObject;

@WebServlet("/project/RstBookmarkServlet")
public class RstBookmarkServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	    request.setCharacterEncoding("UTF-8");
	    response.setContentType("application/json; charset=UTF-8");

	    HttpSession session = request.getSession();
	    String id = (String) session.getAttribute("idKey");

	    String rstIdStr = request.getParameter("rst_id");

	    PrintWriter out = response.getWriter();
	    JSONObject json = new JSONObject();

	    if (id == null) {
	        json.put("success", false);
	        json.put("message", "로그인이 필요합니다.");
	        out.write(json.toString());
	        return;
	    }

	    try {
	        int rst_id = Integer.parseInt(rstIdStr);
	        BookmarkMgr mgr = new BookmarkMgr();

	        boolean alreadyBookmarked = mgr.checkBookmark(id, rst_id);
	        boolean result = alreadyBookmarked
	                ? mgr.removeBookmark(id, rst_id)
	                : mgr.addBookmark(id, rst_id);

	        if (result) {
	            int newCount = mgr.countBookmark(rst_id);
	            json.put("success", true);
	            json.put("bookmarked", !alreadyBookmarked);
	            json.put("bookmarkCount", newCount);
	        } else {
	            json.put("success", false);
	            json.put("message", "처리 중 오류가 발생했습니다.");
	        }
	    } catch (Exception e) {
	        json.put("success", false);
	        json.put("message", "잘못된 요청입니다.");
	        e.printStackTrace();  // 디버깅에 도움됨
	    }

	    out.write(json.toString());
	}

}
