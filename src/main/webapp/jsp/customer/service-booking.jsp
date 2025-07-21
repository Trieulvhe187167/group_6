<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="model.Service" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Book Services</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">


        <style>
            /* Container chung */
            .services-section {
                background: #f8f9fa;
                padding: 20px;
                border-radius: 10px;
                margin-bottom: 20px;
            }

            /* Header */
            .services-header {
                display: flex;
                align-items: center;
                margin-bottom: 15px;
                border-bottom: 1px solid #e0e0e0;
                padding-bottom: 8px;
            }
            .services-header .service-icon {
                color: #ff6b6b;
                margin-right: 8px;
                font-size: 1.2rem;
            }
            .services-header .badge {
                margin-left: auto;
                background: #eee;
                color: #666;
                padding: 3px 10px;
                border-radius: 12px;
                font-size: 0.85rem;
            }
            .services-header .selected-services-count {
                margin-left: 12px;
                background: #ff6b6b;
                color: #fff;
                padding: 3px 12px;
                border-radius: 15px;
                font-size: 0.85rem;
                display: none;
            }

            /* Tabs category */
            .service-categories {
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
                margin-bottom: 12px;
            }
            .category-tab {
                padding: 6px 14px;
                border: 1px solid #ddd;
                border-radius: 20px;
                background: #fff;
                cursor: pointer;
                transition: background 0.3s, color 0.3s;
                font-size: 0.9rem;
            }
            .category-tab.active,
            .category-tab:hover {
                background: #ff6b6b;
                color: #fff;
                border-color: #ff6b6b;
            }

            /* Danh sách services cuộn được */
            #servicesContainer {
                max-height: 300px;
                overflow-y: auto;
                padding-right: 6px;
            }
            #servicesContainer::-webkit-scrollbar {
                width: 6px;
            }
            #servicesContainer::-webkit-scrollbar-thumb {
                background: #ff6b6b;
                border-radius: 3px;
            }
            .remove-btn {
                margin-left: 6px;
            }
            .btn-close.remove-btn {
                filter: invert(18%) sepia(92%) saturate(7481%) hue-rotate(345deg) brightness(95%) contrast(94%) !important;
                opacity: 0.8;
            }

            .btn-close.remove-btn:hover {
                --bs-close-color: #a71d2a;
                opacity: 1;
            }
            /* Mỗi item service */
            .service-item {
                display: flex;
                align-items: center;
                padding: 12px;
                border: 1px solid #eee;
                border-radius: 8px;
                margin-bottom: 10px;
                background: #fff;
                transition: background 0.3s, border-color 0.3s;
            }
            .service-item:hover,
            .service-item.selected {
                background: #fff5f5;
                border-color: #ff6b6b;
            }
            .service-item input[type="checkbox"] {
                margin-right: 12px;
                width: 18px;
                height: 18px;
            }
            .service-info {
                flex: 1;
            }
            .service-info strong {
                display: flex;
                align-items: center;
                font-size: 1rem;
                color: #333;
            }
            .service-info .service-icon {
                margin-right: 6px;
                color: #ff6b6b;
            }
            .service-info .category-badge {
                margin-left: 8px;
                background: #eee;
                color: #666;
                padding: 2px 8px;
                border-radius: 12px;
                font-size: 0.75rem;
            }
            .service-info .text-muted {
                font-size: 0.85rem;
                color: #666;
                margin-top: 4px;
            }
            .service-price {
                font-size: 1rem;
                font-weight: 600;
                color: #ff6b6b;
                white-space: nowrap;
                margin-left: 12px;
            }



            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
            }

            .dashboard-container {
                display: flex;
                min-height: 100vh;
            }

            /* Sidebar Styles */
            .sidebar {
                width: 280px;
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(10px);
                box-shadow: 4px 0 20px rgba(0, 0, 0, 0.1);
                padding: 0;
                position: fixed;
                height: 100vh;
                z-index: 1000;
                transition: transform 0.3s ease;
            }

            .sidebar-header {
                padding: 30px 25px;
                background: linear-gradient(135deg, #667eea, #764ba2);
                color: white;
                text-align: center;
                border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            }

            .sidebar-header h3 {
                font-size: 1.4rem;
                font-weight: 600;
                margin-bottom: 5px;
            }

            .sidebar-header p {
                font-size: 0.9rem;
                opacity: 0.8;
            }

            .sidebar-menu {
                list-style: none;
                padding: 20px 0;
            }

            .sidebar-menu li {
                margin: 0;
            }

            .sidebar-menu a {
                display: flex;
                align-items: center;
                padding: 15px 25px;
                color: #495057;
                text-decoration: none;
                transition: all 0.3s ease;
                border-left: 3px solid transparent;
            }

            .sidebar-menu a:hover {
                background: linear-gradient(90deg, rgba(102, 126, 234, 0.1), transparent);
                border-left-color: #667eea;
                color: #667eea;
            }

            .sidebar-menu a.active {
                background: linear-gradient(90deg, rgba(102, 126, 234, 0.15), transparent);
                border-left-color: #667eea;
                color: #667eea;
                font-weight: 600;
            }

            .sidebar-menu i {
                width: 20px;
                margin-right: 15px;
                font-size: 1.1rem;
            }

            .menu-divider {
                height: 1px;
                background: linear-gradient(90deg, transparent, #e9ecef, transparent);
                margin: 15px 0;
            }

            /* Mobile Toggle */
            .mobile-toggle {
                display: none;
                position: fixed;
                top: 20px;
                left: 20px;
                z-index: 1001;
                background: #667eea;
                color: white;
                border: none;
                border-radius: 50%;
                width: 50px;
                height: 50px;
                font-size: 1.2rem;
                cursor: pointer;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
                transition: all 0.3s ease;
            }

            .mobile-toggle:hover {
                background: #764ba2;
                transform: scale(1.05);
            }

            /* Main Content */
            .main-content {
                flex: 1;
                margin-left: 280px;
                padding: 40px;
                transition: margin-left 0.3s ease;
            }

            .content-header {
                background: rgba(255, 255, 255, 0.9);
                backdrop-filter: blur(10px);
                border-radius: 15px;
                padding: 30px;
                margin-bottom: 30px;
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            }

            .content-header h2 {
                color: #343a40;
                font-size: 2rem;
                font-weight: 700;
                margin-bottom: 10px;
            }

            .content-header p {
                color: #6c757d;
                font-size: 1.1rem;
            }
            .selected-summary {
                max-height: 300px;
                overflow-y: auto;
            }
            .selected-summary .list-group-item {
                display: flex;
                align-items: center;
            }
            .qty-controls {
                display: flex;
                align-items: center;
                margin-left: auto;
                margin-right: 10px;
            }
            .qty-controls input {
                width: 60px;
                text-align: center;
            }
            .item-total {
                white-space: nowrap;
            }

        </style>
    </head>
    <body>
        <!-- Mobile Toggle Button -->
        <button class="mobile-toggle" onclick="toggleSidebar()">
            <i class="fas fa-bars"></i>
        </button>

        <!-- Sidebar Overlay -->
        <div class="sidebar-overlay" onclick="toggleSidebar()"></div>

        <div class="dashboard-container">
            <!-- Sidebar -->
            <nav class="sidebar" id="sidebar">
                <div class="sidebar-header">
                    <h3><i class="fas fa-user-circle"></i> Customer Panel</h3>
                    <p>Welcome back!</p>
                </div>
                <ul class="sidebar-menu">
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/bookings">
                            <i class="fas fa-calendar-check"></i>
                            <span>My Bookings</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/history">
                            <i class="fas fa-history"></i>
                            <span>Booking History</span>
                        </a>
                    </li>
                    <div class="menu-divider"></div>
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/profile">
                            <i class="fas fa-user-edit"></i>
                            <span>User Profile</span>
                        </a>
                    </li>



                    <li>
                        <a href="${pageContext.request.contextPath}/customer/services" class="active">
                            <i class="fa fa-concierge-bell"></i> Book Services
                        </a>
                    </li>
                    <div class="menu-divider"></div>
                    <li>
                        <a href="/index.jsp">
                            <i class="fas fa-home"></i>
                            <span>Homepage</span>
                        </a>
                    </li>
                    <li>
                        <a href="search-rooms.jsp">
                            <i class="fas fa-search"></i>
                            <span>Search Rooms</span>
                        </a>
                    </li>
                    <li>
                        <a href="support.jsp">
                            <i class="fas fa-headset"></i>
                            <span>Support</span>
                        </a>
                    </li>
                    <div class="menu-divider"></div>
                    <li>
                        <a href="${pageContext.request.contextPath}/LogoutServlet" style="color: #dc3545;">
                            <i class="fas fa-sign-out-alt"></i>
                            <span>Logout</span>
                        </a>
                    </li>
                </ul>
            </nav>


            <main class="main-content">
                <div class="container mt-4">
                    <h2 class="mb-3">Book Additional Services</h2>
                    <c:if test="${not empty sessionScope.success}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            ${sessionScope.success}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                        <c:remove var="success" scope="session"/>
                    </c:if>
                    <c:if test="${not empty sessionScope.error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            ${sessionScope.error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                        <c:remove var="error" scope="session"/>
                    </c:if>
                    <c:if test="${empty reservations}">
                        <div class="alert alert-info">You have no active reservations.</div>
                    </c:if>
                    <c:if test="${not empty reservations}">
                        <form id="serviceForm" method="post" action="${pageContext.request.contextPath}/customer/services">                            <input type="hidden" name="action" value="add">
                            <input type="hidden" name="reservationId" value="${selectedId}">
                            <div class="mb-3">
                                <label class="form-label">Select Reservation</label>

                                <select class="form-select" onchange="location.href = '${pageContext.request.contextPath}/customer/services?resId=' + this.value">
                                    <c:forEach var="r" items="${reservations}">
                                        <option value="${r.id}" ${r.id==selectedId ? 'selected' : ''}>Room ${r.roomNumber} (${r.checkIn} - ${r.checkOut})</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <!-- Enhanced Additional Services Section -->
                            <div class="services-section mb-3">
                                <div class="services-header">
                                    <h4><i class="fa fa-concierge-bell service-icon"></i> Additional Services</h4>
                                    <span class="badge">Optional</span>
                                    <span class="selected-services-count" id="selectedServicesCount" style="display:none;">0 selected</span>
                                </div>
                                <div class="row">
                                    <div class="col-md-7">
                                        <div class="service-categories mb-2">
                                            <div class="category-tab active" onclick="filterServices('all', event)">All Services</div>
                                            <div class="category-tab" onclick="filterServices('TRANSPORT', event)">Transportation</div>
                                            <div class="category-tab" onclick="filterServices('DINING', event)">Dining</div>
                                            <div class="category-tab" onclick="filterServices('SPA', event)">Spa & Wellness</div>
                                            <div class="category-tab" onclick="filterServices('SPECIAL', event)">Special Services</div>
                                        </div>
                                        <div id="servicesContainer">


                                            <% java.text.DecimalFormat df = new java.text.DecimalFormat("#,##0"); %>
                                            <% for(model.Service service : (java.util.List<model.Service>)request.getAttribute("services")) { %>
                                            <% String category="OTHER"; String n=service.getName().toLowerCase(); String d=(service.getDescription()==null?"":service.getDescription().toLowerCase());
                        if(n.contains("airport")||n.contains("shuttle")||n.contains("tour")||n.contains("car")) category="TRANSPORT"; else if(n.contains("breakfast")||n.contains("dinner")||n.contains("room service")||n.contains("mini bar")) category="DINING"; else if(n.contains("spa")||n.contains("massage")||n.contains("yoga")) category="SPA"; else if(n.contains("flower")||n.contains("birthday")||n.contains("honeymoon")||n.contains("laundry")) category="SPECIAL"; %>
                                            <div class="service-item" data-category="<%=category%>" tabindex="0">
                                                <label style="display:flex;align-items:center;width:100%;cursor:pointer;margin:0;">
                                                    <input type="checkbox" name="serviceIds" value="<%=service.getId()%>" data-name="<%=service.getName()%>" data-price="<%=service.getPrice()%>" onchange="updateSelectedCount()">
                                                    <div class="service-info ms-2">
                                                        <strong><%=service.getName()%></strong>
                                                        <div class="category-badge"><%=category%></div>
                                                        <div class="text-muted small"><%=service.getDescription()%></div>
                                                    </div>
                                                    <div class="ms-auto service-price"><%=df.format(service.getPrice())%>₫</div>
                                                </label>
                                            </div>
                                            <% } %>
                                        </div>
                                        <div class="text-center mt-2">
                                            <small class="text-muted"><i class="fa fa-mouse-pointer"></i> Click categories to filter</small>
                                        </div>
                                    </div>
                                    <div class="col-md-5">
                                        <div class="card h-100">
                                            <div class="card-header">Selected Services</div>
                                            <ul class="list-group list-group-flush selected-summary" id="summaryList"></ul>
                                            <div class="card-footer">
                                                <div class="d-flex justify-content-between mb-2">
                                                    <strong>Total:</strong>
                                                    <span id="summaryTotal">0₫</span>
                                                </div>
                                                <button type="submit" class="btn btn-primary w-100">Confirm Booking</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>


                        </form>


                        <c:if test="${not empty cart}">
                            <h4 class="mt-4">Current Services</h4>
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th>Service</th>
                                        <th>Qty</th>
                                        <th>Unit Price</th>
                                        <th>Total</th>
                                        <th>Status</th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:set var="grand" value="0" />
                                    <c:forEach var="c" items="${cart}">
                                        <tr>
                                            <td>${c.serviceName}</td>
                                            <td>${c.quantity}</td>
                                            <td><fmt:formatNumber value="${c.unitPrice}" pattern="#,#00"/>₫</td>
                                            <td><fmt:formatNumber value="${c.totalAmount}" pattern="#,#00"/>₫</td>
                                            <td>${c.status}</td>
                                            <td>
                                                <form method="post" action="${pageContext.request.contextPath}/customer/services" onsubmit="return confirm('Cancel service?');">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="reservationId" value="${selectedId}">
                                                    <input type="hidden" name="lineId" value="${c.id}">
                                                    <button class="btn btn-sm btn-danger">Cancel Service</button>
                                                </form>
                                            </td>
                                        </tr>
                                        <c:set var="grand" value="${grand + c.totalAmount}" />
                                    </c:forEach>
                                </tbody>
                                <tfoot>
                                    <tr>
                                        <th colspan="3" class="text-end">Total Amount:</th>
                                        <th><fmt:formatNumber value="${grand}" pattern="#,#00"/>₫</th>
                                        <th colspan="2"></th>
                                    </tr>
                                </tfoot>
                            </table>
                        </c:if>
                    </c:if>
                </div>
            </main>
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
            <script>
                                                    function filterServices(category, ev) {
                                                        document.querySelectorAll('.category-tab').forEach(t => t.classList.remove('active'));
                                                        if (ev)
                                                            ev.target.classList.add('active');
                                                        document.querySelectorAll('.service-item').forEach(item => {
                                                            item.style.display = (category === 'all' || item.dataset.category === category) ? 'flex' : 'none';
                                                        });
                                                    }
                                                    function updateSelectedCount() {
                                                        const count = document.querySelectorAll('input[name="serviceIds"]:checked').length;
                                                        const el = document.getElementById('selectedServicesCount');
                                                        if (el) {
                                                            if (count > 0) {
                                                                el.textContent = count + ' selected';
                                                                el.style.display = 'inline-block';
                                                            } else {
                                                                el.style.display = 'none';
                                                            }
                                                        }
                                                        updateSummary();
                                                    }

                                                    function updateSummary() {
                                                        const summary = document.getElementById('summaryList');
                                                        const totalEl = document.getElementById('summaryTotal');
                                                        const form = document.getElementById('serviceForm');
                                                        if (!summary || !totalEl || !form)
                                                            return;
                                                        summary.innerHTML = '';
                                                        form.querySelectorAll('.dynamic-input').forEach(e => e.remove());
                                                        document.querySelectorAll('input[name="serviceIds"]:checked').forEach(cb => {

                                                            const id = cb.value;
                                                            const name = cb.dataset.name;
                                                            const price = parseFloat(cb.dataset.price);

                                                            const li = document.createElement('li');
                                                            li.className = 'list-group-item';
                                                            li.dataset.price = price;

                                                            const remove = document.createElement('button');
                                                            remove.type = 'button';
                                                            remove.className = 'btn-close remove-btn';
                                                            remove.addEventListener('click', () => {
                                                                cb.checked = false;
                                                                updateSelectedCount();
                                                            });
                                                            li.appendChild(remove);

                                                            const nameSpan = document.createElement('span');
                                                            nameSpan.textContent = name;
                                                            li.appendChild(nameSpan);

                                                            const qtyWrap = document.createElement('div');
                                                            qtyWrap.className = 'qty-controls';
                                                            const minus = document.createElement('button');
                                                            minus.type = 'button';
                                                            minus.className = 'btn btn-sm btn-outline-secondary';
                                                            minus.textContent = '-';
                                                            const qtyInput = document.createElement('input');
                                                            qtyInput.type = 'number';
                                                            qtyInput.min = '1';
                                                            qtyInput.value = '1';
                                                            qtyInput.className = 'form-control form-control-sm mx-1 qty-input';
                                                            const plus = document.createElement('button');
                                                            plus.type = 'button';
                                                            plus.className = 'btn btn-sm btn-outline-secondary';
                                                            plus.textContent = '+';
                                                            qtyWrap.appendChild(minus);
                                                            qtyWrap.appendChild(qtyInput);
                                                            qtyWrap.appendChild(plus);
                                                            li.appendChild(qtyWrap);

                                                            const totalSpan = document.createElement('span');
                                                            totalSpan.className = 'item-total';
                                                            totalSpan.textContent = price.toLocaleString() + '₫';
                                                            li.appendChild(totalSpan);

                                                            summary.appendChild(li);

                                                            const idInput = document.createElement('input');
                                                            idInput.type = 'hidden';
                                                            idInput.name = 'serviceIds';
                                                            idInput.value = id;
                                                            idInput.className = 'dynamic-input';
                                                            const qtyHidden = document.createElement('input');
                                                            qtyHidden.type = 'hidden';
                                                            qtyHidden.name = 'quantities';
                                                            qtyHidden.value = '1';
                                                            qtyHidden.className = 'dynamic-input';
                                                            form.appendChild(idInput);
                                                            form.appendChild(qtyHidden);

                                                            function updateItem() {
                                                                let q = parseInt(qtyInput.value);
                                                                if (isNaN(q) || q < 1) {
                                                                    q = 1;
                                                                    qtyInput.value = '1';
                                                                }
                                                                qtyHidden.value = q;
                                                                totalSpan.textContent = (price * q).toLocaleString() + '₫';
                                                                updateTotals();
                                                            }
                                                            minus.addEventListener('click', () => {
                                                                if (parseInt(qtyInput.value) > 1) {
                                                                    qtyInput.value--;
                                                                    updateItem();
                                                                }
                                                            });
                                                            plus.addEventListener('click', () => {
                                                                qtyInput.value++;
                                                                updateItem();
                                                            });
                                                            qtyInput.addEventListener('change', updateItem);
                                                        });
                                                        updateTotals();
                                                    }

                                                    function updateTotals() {
                                                        let total = 0;
                                                        document.querySelectorAll('#summaryList li').forEach(li => {
                                                            const price = parseFloat(li.dataset.price);
                                                            const qty = parseInt(li.querySelector('.qty-input').value);
                                                            total += price * qty;
                                                        });
                                                        const totalEl = document.getElementById('summaryTotal');
                                                        if (totalEl)
                                                            totalEl.textContent = total.toLocaleString() + '₫';
                                                    }
            </script>
    </body>
</html>