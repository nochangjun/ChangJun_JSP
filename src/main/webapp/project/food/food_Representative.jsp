<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>제주도 대표 음식</title>
    <link rel="stylesheet" href="../css/food_Representative.css">
        <jsp:include page="../header.jsp" />
</head>
<body>
	<!-- Header Banner -->
    <div class="banner">
        <img src="../img/제주도 해변.png" alt="제주도 해변">
    </div>
        
    <div class="container">
        <!-- Main Title -->
        <div class="main-title">
            <h1>제주도 대표 음식</h1>
            <div class="title-underline"></div>
            <p>제주의 독특한 자연환경과 문화가 만들어낸 맛있는 제주 음식을 소개합니다.</p>
        </div>
        
        <!-- Food Grid -->
        <div class="food-grid">
            <!-- 제주 흑돼지 -->
            <div class="food-card">
                <div class="food-image">
                    <img src="../img/제주 흑돼지.png" alt="제주 흑돼지">
                </div>
                <div class="food-info">
                    <div class="food-header">
                        <h3>제주 흑돼지</h3>
                    </div>
                    <p class="description">제주의 대표적인 특산품인 흑돼지는 쫄깃한 식감과 담백한 맛으로 유명합니다. 제주에서 꼭 먹어봐야 할 음식 중 하나입니다.</p>
                    <div class="tags">
                        <span class="tag">맛집</span>
                        <span class="tag">제주도</span>
                        <span class="tag">흑돼지</span>
                    </div>
                    <div class="buttons">
                        <a href="/myapp/project/rst/rst_Find.jsp?tag=흑돼지&region=" class="view-btn">맛집 찾기</a>
                    </div>
                </div>
            </div>
            
            <!-- 갈치국 -->
            <div class="food-card">
                <div class="food-image">
                    <img src="../img/갈치국.png" alt="갈치국">
                </div>
                <div class="food-info">
                    <div class="food-header">
                        <h3>갈치국</h3>
                    </div>
                    <p class="description">제주 바다에서 잡히는 싱싱한 갈치로 끓인 국으로, 시원한 맛이 일품입니다. 제주 현지인들이 즐겨 먹는 향토 음식입니다.</p>
                    <div class="tags">
                        <span class="tag">맛집</span>
                        <span class="tag">제주도</span>
                        <span class="tag">해산물</span>
                        <span class="tag">국물요리</span>
                    </div>
                    <div class="buttons">
                        <a href="/myapp/project/rst/rst_Find.jsp?tag=갈치국&region=" class="view-btn">맛집 찾기</a>
                    </div>
                </div>
            </div>
            
            <!-- 고기국수 -->
            <div class="food-card">
                <div class="food-image">
                    <img src="../img/고기국수.png" alt="고기국수">
                </div>
                <div class="food-info">
                    <div class="food-header">
                        <h3>고기국수</h3>
                    </div>
                    <p class="description">제주산 돼지고기로 육수를 우려내어 만든 국수로, 담백하고 구수한 맛이 특징입니다. 제주도민의 소울푸드입니다.</p>
                    <div class="tags">
                        <span class="tag">맛집</span>
                        <span class="tag">제주도</span>
                        <span class="tag">국수</span>
                        <span class="tag">돼지고기</span>
                    </div>
                    <div class="buttons">
                        <a href="/myapp/project/rst/rst_Find.jsp?tag=고기국수&region=" class="view-btn">맛집 찾기</a>
                    </div>
                </div>
            </div>
            
            <!-- 옥돔구이 -->
            <div class="food-card">
                <div class="food-image">
                    <img src="../img/옥돔구이.png" alt="옥돔구이">
                </div>
                <div class="food-info">
                    <div class="food-header">
                        <h3>옥돔구이</h3>
                    </div>
                    <p class="description">제주 연안에서 잡히는 고급 생선인 옥돔을 소금에 절여 구운 음식으로, 담백하고 고소한 맛이 특징입니다.</p>
                    <div class="tags">
                        <span class="tag">맛집</span>
                        <span class="tag">제주도</span>
                        <span class="tag">해산물</span>
                        <span class="tag">구이</span>
                    </div>
                    <div class="buttons">
                        <a href="/myapp/project/rst/rst_Find.jsp?tag=옥돔구이&region=" class="view-btn">맛집 찾기</a>
                    </div>
                </div>
            </div>
            
            <!-- 성게 미역국 -->
            <div class="food-card">
                <div class="food-image">
                    <img src="../img/성게 미역국.png" alt="성게 미역국">
                </div>
                <div class="food-info">
                    <div class="food-header">
                        <h3>성게 미역국</h3>
                    </div>
                    <p class="description">제주 바다에서 채취한 신선한 성게와 미역으로 끓인 국으로, 깊은 바다 향과 고소함이 일품인 제주도의 향토 음식입니다.</p>
                    <div class="tags">
                        <span class="tag">맛집</span>
                        <span class="tag">제주도</span>
                        <span class="tag">해산물</span>
                        <span class="tag">국물요리</span>
                    </div>
                    <div class="buttons">
                        <a href="/myapp/project/rst/rst_Find.jsp?tag=성게미역국&region=" class="view-btn">맛집 찾기</a>
                    </div>
                </div>
            </div>
            
            <!-- 빙떡 -->
            <div class="food-card">
                <div class="food-image">
                    <img src="../img/빙떡.png" alt="빙떡">
                </div>
                <div class="food-info">
                    <div class="food-header">
                        <h3>빙떡</h3>
                    </div>
                    <p class="description">메밀가루로 만든 얇은 반죽에 무채와 팥소를 넣어 만든 제주도의 전통 간식으로, 쫄깃하고 담백한 맛이 특징입니다.</p>
                    <div class="tags">
                        <span class="tag">맛집</span>
                        <span class="tag">제주도</span>
                        <span class="tag">전통음식</span>
                        <span class="tag">간식</span>
                    </div>
                    <div class="buttons">
                        <a href="/myapp/project/rst/rst_Find.jsp?tag=빙떡&region=" class="view-btn">맛집 찾기</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- 푸터 포함 -->
    <jsp:include page="../footer.jsp" />
</body>
</html>