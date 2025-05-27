package project;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/project/CheckDuplicateServlet")
public class CheckDuplicateServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");
        
        String type = request.getParameter("type");
        String value = request.getParameter("value");

        MemberMgr mgr = new MemberMgr();
        boolean isDuplicate = false;

        if (type == null || value == null || value.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        switch (type) {
            case "nickname":
                isDuplicate = mgr.checkNickname(value);
                break;
            case "phone":
                isDuplicate = mgr.checkPhone(value);
                break;
            case "email":
                isDuplicate = mgr.checkEmail(value);
                break;
            default:
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
        }

        try (PrintWriter out = response.getWriter()) {
            out.print(isDuplicate ? "duplicate" : "available");
        }
	}
}
