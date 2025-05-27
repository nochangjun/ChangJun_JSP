<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div id="footer-root" class="footer-root"></div>

<script>
    // Shadow DOM 생성
    const footerRoot = document.getElementById('footer-root');
    const shadow = footerRoot.attachShadow({ mode: 'closed' }); // 외부 CSS로부터 완전 격리

    // 부모 요소의 스타일 제약 제거
    footerRoot.style.width = '100%';
    footerRoot.style.maxWidth = 'none';
    footerRoot.style.minWidth = '100%';
    footerRoot.style.overflow = 'visible';
    footerRoot.style.display = 'block';
    footerRoot.style.position = 'relative';
    footerRoot.style.margin = '0';
    footerRoot.style.padding = '0';

    // 부모 요소의 스타일 강제 제거
    const parent = footerRoot.parentElement;
    if (parent) {
        parent.style.width = '100%';
        parent.style.maxWidth = 'none';
        parent.style.overflow = 'visible';
        parent.style.display = 'block';
        parent.style.position = 'relative';
        parent.style.margin = '0';
        parent.style.padding = '0';
    }

    // footer.css 동적 로드
    const style = document.createElement('link');
    style.rel = 'stylesheet';
    style.href = '${pageContext.request.contextPath}/project/css/footer.css';
    shadow.appendChild(style);

    // Font Awesome 동적 로드
    const fontAwesome = document.createElement('link');
    fontAwesome.rel = 'stylesheet';
    fontAwesome.href = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css';
    shadow.appendChild(fontAwesome);

    // Google Fonts 동적 로드
    const googleFonts = document.createElement('link');
    googleFonts.rel = 'stylesheet';
    googleFonts.href = 'https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap';
    shadow.appendChild(googleFonts);

    // HTML 콘텐츠 추가
    const container = document.createElement('div');
    container.className = 'footer-root';
    container.innerHTML = `
        <header class="header-container">
            <div class="logo-slider">
                <button class="nav-arrow prev-arrow"><i class="fas fa-chevron-left"></i></button>
                <img src="${pageContext.request.contextPath}/project/img/제주특별자치도.png" alt="제주특별자치도">
                <img src="${pageContext.request.contextPath}/project/img/제주관광공사.png" alt="제주관광공사">
                <img src="${pageContext.request.contextPath}/project/img/제주특별자치도관광협회.png" alt="제주특별자치도관광협회">
                <img src="${pageContext.request.contextPath}/project/img/제주컨벤션뷰로.png" alt="Jeju CVB">
                <img src="${pageContext.request.contextPath}/project/img/icc-jeju.png" alt="ICC JEJU">
                <button class="nav-arrow next-arrow"><i class="fas fa-chevron-right"></i></button>
            </div>
        </header>

        <nav class="main-navigation">
            <a href="#" class="nav-item">
                <div class="nav-icon">
                    <img src="${pageContext.request.contextPath}/project/img/장애인 관광정보.png" alt="접근성 아이콘">
                </div>
                <span class="nav-label">장애인 관광정보</span>
            </a>
            <a href="#" class="nav-item">
                <div class="nav-icon">
                    <img src="${pageContext.request.contextPath}/project/img/제주관광정보센터.png" alt="정보 아이콘">
                </div>
                <span class="nav-label">제주관광정보센터</span>
            </a>
            <a href="#" class="nav-item">
                <div class="nav-icon">
                    <img src="${pageContext.request.contextPath}/project/img/제주 관광지도.png" alt="지도 아이콘">
                </div>
                <span class="nav-label">제주 관광지도</span>
            </a>
            <a href="#" class="nav-item">
                <div class="nav-icon">
                    <img src="${pageContext.request.contextPath}/project/img/업체정보수정신청.png" alt="수정 아이콘">
                </div>
                <span class="nav-label">업체정보수정신청</span>
            </a>
            <a href="#" class="nav-item">
                <div class="nav-icon">
                    <img src="${pageContext.request.contextPath}/project/img/관광업체등록신청.png" alt="등록 아이콘">
                </div>
                <span class="nav-label">관광업체등록신청</span>
            </a>
            <a href="#" class="nav-item">
                <div class="nav-icon">
                    <img src="${pageContext.request.contextPath}/project/img/포토제주.png" alt="포토제주 아이콘">
                </div>
                <span class="nav-label">포토제주</span>
            </a>
        </nav>

        <section class="menu-section">
            <div class="menu-category">
                <h3 class="menu-title">가게 등록</h3>
                <ul class="menu-list">
                <li class="menu-item">
                <a href="${pageContext.request.contextPath}/project/store/store_Register.jsp" class="menu-link">등록 폼 양식</a>
            </li>
                </ul>
            </div>
            <div class="menu-category">
                <h3 class="menu-title">음식</h3>
                <ul class="menu-list">
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/project/food/food_Representative.jsp" class="menu-link">대표음식</a>
                    </li>
                </ul>
            </div>
            <div class="menu-category">
                <h3 class="menu-title">맛집</h3>
                <ul class="menu-list">
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/project/rst/rst_Course_List.jsp" class="menu-link">하루 맛집 코스</a>
                    </li>
                </ul>
            </div>
            <div class="menu-category">
                <h3 class="menu-title">이벤트</h3>
                <ul class="menu-list">
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/project/event/event.jsp" class="menu-link">맛집 이벤트</a>
                    </li>
                </ul>
            </div>
            <div class="menu-category">
                <h3 class="menu-title">나의 맛집</h3>
                <ul class="menu-list">
                    <li class="menu-item">
                        <a href="javascript:void(0);" class="menu-link" onclick="checkLoginAndGoTo('${pageContext.request.contextPath}/project/my/my_Page.jsp')">마이 페이지</a>
                    </li>
                    <li class="menu-item">
                        <a href="javascript:void(0);" class="menu-link" onclick="checkLoginAndGoTo('${pageContext.request.contextPath}/project/my/my_Update_Profile.jsp')">정보 수정</a>
                    </li>
                </ul>
            </div>
            <div class="menu-category">
                <h3 class="menu-title">고객지원</h3>
                <ul class="menu-list">
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/project/support/support_Board.jsp" class="menu-link">게시판</a>
                    </li>
                    <li class="menu-item">
                        <a href="${pageContext.request.contextPath}/project/support/support_Inquiry.jsp" class="menu-link">문의하기</a>
                    </li>
                </ul>
            </div>
        </section>

        <footer class="footer">
            <div class="footer-container">
                <div class="footer-info">
                    <p>제안정보서비스명칭 &nbsp; 이용약관 &nbsp; 정보공유사이트 &nbsp; 제주관광안내사업홍보 &nbsp; JEJU TourAPI &nbsp; 제주소식 &nbsp; 관광정책통계자료실</p>
                    <p>(63122) 제주특별자치도 제주시 선덕로 23(연동) 제주특별자치도 관광협회 &nbsp; Tel : xxx-xxx-xxxx~x &nbsp; FAX : xxx-xxx-xxxx &nbsp; 사업자등록번호 : xxx-xx-xxxxx</p>
                </div>
                <div class="footer-logos">
                    <img src="${pageContext.request.contextPath}/project/img/과학기술정보.png" alt="Footer Logo 1" class="footer-logo">
                    <img src="${pageContext.request.contextPath}/project/img/유네스코.png" alt="Footer Logo 2" class="footer-logo">
                </div>
            </div>
        </footer>
    `;
    shadow.appendChild(container);

    // JavaScript 추가
    const script = document.createElement('script');
    script.textContent = `
        // Logo Slider 기능
        const prevArrow = shadow.querySelector('.prev-arrow');
        const nextArrow = shadow.querySelector('.next-arrow');
        const logoSlider = shadow.querySelector('.logo-slider');
        const logos = logoSlider.querySelectorAll('img');
        
        let currentIndex = 0;
        const logoCount = logos.length;
        
        prevArrow.addEventListener('click', function() {
            currentIndex = (currentIndex - 1 + logoCount) % logoCount;
            updateSlider();
        });
        
        nextArrow.addEventListener('click', function() {
            currentIndex = (currentIndex + 1) % logoCount;
            updateSlider();
        });
        
        function updateSlider() {
            logos.forEach((logo, index) => {
                const position = (index - currentIndex + logoCount) % logoCount;
                logo.style.order = position;
                logo.style.opacity = position < 3 ? '1' : '0.5';
            });
        }

        updateSlider();
        
        // 네비게이션 아이콘 클릭 방지
        const navItems = shadow.querySelectorAll('.nav-item');
        navItems.forEach(item => {
            item.addEventListener('click', function(e) {
                if(this.getAttribute('href') === '#') {
                    e.preventDefault();
                }
            });
        });

        // 로그인 체크 함수
        function checkLoginAndGoTo(url) {
            const isLoggedIn = <%=session.getAttribute("idKey") != null%>
            if (!isLoggedIn) {
            	document.getElementById("yummy-loginAlertModal").style.display = "flex";
            } else {
                window.location.href = url;
            }
        }

        // 부모 스타일 간섭 방지 (주기적 확인)
        setInterval(() => {
            const root = document.getElementById('footer-root');
            const parent = root.parentElement;
            if (root && parent) {
                root.style.width = '100%';
                root.style.maxWidth = 'none';
                root.style.minWidth = '100%';
                root.style.overflow = 'visible';
                root.style.display = 'block';
                root.style.position = 'relative';
                root.style.margin = '0';
                root.style.padding = '0';
                
                parent.style.width = '100%';
                parent.style.maxWidth = 'none';
                parent.style.overflow = 'visible';
                parent.style.display = 'block';
                parent.style.position = 'relative';
                parent.style.margin = '0';
                parent.style.padding = '0';
            }
        }, 100);
    `;
    shadow.appendChild(script);
    
  //로그인 페이지로 이동
    function goToLogin() {
      const currentUrl = window.location.pathname + window.location.search;
      const encodedUrl = encodeURIComponent(currentUrl);

      window.location.href = "<%=request.getContextPath()%>/project/login/login.jsp?url=" + encodedUrl;
  }

    // 로그인 경고 모달 닫기
    function closeLoginModal() {
        document.getElementById("yummy-loginAlertModal").style.display = "none";
    }

</script>