package project;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/project/login/CheckNicknameServlet")
public class CheckNicknameServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/plain; charset=UTF-8");
        String nickname = request.getParameter("nickname");
        
        MemberMgr mgr = new MemberMgr();
        boolean isDuplicate = mgr.checkNickname(nickname);
        
        response.getWriter().write(String.valueOf(isDuplicate));
	}
}
