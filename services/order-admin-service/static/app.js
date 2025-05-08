document.addEventListener('DOMContentLoaded', () => {
    const ordersTableBody = document.getElementById('ordersTableBody');
    const connectionStatusDiv = document.getElementById('connectionStatus');
    const noOrdersMessageDiv = document.getElementById('noOrdersMessage');
    const loader = connectionStatusDiv.querySelector('.loader');

    let ordersMap = new Map(); // To store orders by ID for easy update/check

    function updateConnectionStatus(message, isConnected) {
        connectionStatusDiv.textContent = message;
        if (isConnected) {
            connectionStatusDiv.className = 'connection-status status-connected';
            if(loader) loader.style.display = 'none';
        } else {
            connectionStatusDiv.className = 'connection-status status-disconnected';
            if(loader) loader.style.display = 'block'; 
        }
    }

    function timeAgo(timestamp) {
        if (!timestamp) return 'N/A';

        const now = new Date();
        // Backend sends google.protobuf.Timestamp which is { seconds: ..., nanos: ...}
        // Or sometimes it might be an ISO string if previously marshalled/unmarshalled
        let pastDate;
        if (typeof timestamp === 'object' && timestamp.seconds !== undefined) {
            pastDate = new Date(timestamp.seconds * 1000 + (timestamp.nanos || 0) / 1000000);
        } else if (typeof timestamp === 'string') {
            pastDate = new Date(timestamp);
        } else {
            return 'Invalid Date';
        }

        const seconds = Math.floor((now - pastDate) / 1000);
        let interval = Math.floor(seconds / 31536000);

        if (interval > 1) return interval + " years ago";
        interval = Math.floor(seconds / 2592000);
        if (interval > 1) return interval + " months ago";
        interval = Math.floor(seconds / 86400);
        if (interval > 1) return interval + " days ago";
        interval = Math.floor(seconds / 3600);
        if (interval > 1) return interval + " hours ago";
        interval = Math.floor(seconds / 60);
        if (interval > 1) return interval + " minutes ago";
        if (seconds < 10) return "just now";
        return Math.floor(seconds) + " seconds ago";
    }

    function displayNoOrdersMessage() {
        if (ordersMap.size === 0) {
            noOrdersMessageDiv.style.display = 'block';
        } else {
            noOrdersMessageDiv.style.display = 'none';
        }
    }

    function addOrUpdateOrderInTable(order) {
        let row = document.getElementById(`order-${order.order_id}`);
        const isNewRow = !row;

        if (!row) {
            row = ordersTableBody.insertRow(); // Add to the top for new orders
            row.id = `order-${order.order_id}`;
        }

        // Clear existing cells if updating
        while (row.firstChild) {
            row.removeChild(row.firstChild);
        }

        row.insertCell().textContent = order.order_id;
        row.insertCell().textContent = order.customer_id;
        row.insertCell().textContent = typeof order.amount === 'number' ? order.amount.toFixed(2) : 'N/A';
        row.insertCell().textContent = order.description || '';
        
        const statusCell = row.insertCell();
        const statusSpan = document.createElement('span');
        statusSpan.className = `status status-${(order.status || 'UNKNOWN').toUpperCase()}`;
        statusSpan.textContent = order.status || 'UNKNOWN';
        statusCell.appendChild(statusSpan);

        const createdAtCell = row.insertCell();
        createdAtCell.textContent = timeAgo(order.created_at);
        createdAtCell.dataset.timestamp = order.created_at && order.created_at.seconds ? order.created_at.seconds : new Date(order.created_at).getTime()/1000;

        const updatedAtCell = row.insertCell();
        updatedAtCell.textContent = timeAgo(order.updated_at);
        updatedAtCell.dataset.timestamp = order.updated_at && order.updated_at.seconds ? order.updated_at.seconds : new Date(order.updated_at).getTime()/1000;
        
        // If it's a new order, add to map and sort the table rows by creation time (newest first)
        ordersMap.set(order.order_id, order);
        sortOrderTable();
        displayNoOrdersMessage();
    }

    function sortOrderTable() {
        const rows = Array.from(ordersTableBody.querySelectorAll('tr'));
        rows.sort((a, b) => {
            const timeA = parseFloat(a.cells[5].dataset.timestamp || 0); // Assuming created_at is the 6th cell (index 5)
            const timeB = parseFloat(b.cells[5].dataset.timestamp || 0);
            return timeB - timeA; // Sort descending (newest first)
        });
        rows.forEach(row => ordersTableBody.appendChild(row));
    }

    function connectSSE() {
        updateConnectionStatus('Connecting to order stream...', false);
        const eventSource = new EventSource('/sse/orders');

        eventSource.onopen = () => {
            updateConnectionStatus('Connected to order stream. Waiting for orders...', true);
            displayNoOrdersMessage(); // Check if initially empty
        };

        eventSource.onmessage = (event) => {
            try {
                const order = JSON.parse(event.data);
                // Handle initial connection message from server
                if (order.message && order.message === "Connected to order stream!") {
                    console.log("SSE connection confirmed by server.");
                    return;
                }
                addOrUpdateOrderInTable(order);
            } catch (e) {
                console.error('Failed to parse order data:', event.data, e);
            }
        };

        eventSource.onerror = (err) => {
            console.error('EventSource failed:', err);
            updateConnectionStatus('Disconnected. Attempting to reconnect...', false);
            eventSource.close();
            // Implement a backoff strategy for reconnection if desired
            setTimeout(connectSSE, 5000); // Reconnect after 5 seconds
        };
    }

    // Update timeago every 30 seconds
    setInterval(() => {
        document.querySelectorAll('#ordersTableBody tr').forEach(row => {
            if (row.cells[5] && row.cells[5].dataset.timestamp) {
                row.cells[5].textContent = timeAgo({ seconds: parseInt(row.cells[5].dataset.timestamp) });
            }
            if (row.cells[6] && row.cells[6].dataset.timestamp) {
                row.cells[6].textContent = timeAgo({ seconds: parseInt(row.cells[6].dataset.timestamp) });
            }
        });
    }, 30000);

    // Initial connection
    connectSSE();
    displayNoOrdersMessage(); // Initial check
});
