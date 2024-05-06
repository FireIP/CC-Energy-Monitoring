local fcp = {}

local function packet(t, s, a, d)
	local p = {type=t, seq=s, ack=a, dat=d}
	return p
end

function fcp.open(localCh, remoteCh, a, timeout, n)
	local self = {}

	self.localCH = localCh
	self.remoteCh = remoteCh

	self.myAktSeq = math.random(0, 255)
	a.transmit(self.remoteCh, self.localCh, packet("SYN", self.myAktSeq))
	self.myAktSeq = self.myAktSeq + 1
	
	if timeout > 0 then
		self.timer = os.startTimer(timeout)
	end

	self.try = 0
	while self.try <= n do
		self.event = {os.pullEvent()}
		if event[1] == "modem_message" and event[5].type == "SYN-ACK" and event[5].ack == self.myAktSeq then
			os.cancelTimer(self.timer)
			self.remAktSeq = event[5].seq +1
			
			a.open(self.localCH)
			a.transmit(self.remoteCh, self.localCH, packet("ACK", self.myAktSeq, self.remAktSeq))
			self.myAktSeq = self.myAktSeq + 1
			--ESTABLISHED--

		elseif event[1] == "timer" then
			self.try = self.try + 1
			if self.try >= n then
				error("socket timeout retry: " .. self.try, 1)
			end
		end
	end
	

	function self.write(s)
		a.transmit(self.remoteCh, self.localCh, packet(t="DAT", self.myAktSeq))
		self.myAktSeq = self.myAktSeq + 1
	end

	function self.read(timeout)
		if timeout > 0 then
			self.timer = os.startTimer(timeout)
		end
		self.event = {os.pullEvent()}
		if event[1] == "modem_message" and event[3] == self.localCH and event[5].type == "DAT" then
			os.cancelTimer(self.timer)
			self.remAktSeq = event[5].seq + 1
			a.transmit(self.remoteCh, self.localCH, packet("ACK", self.myAktSeq, self.remAktSeq))
			self.myAktSeq = self.myAktSeq + 1
			return event[5].dat

		elseif event[1] == "modem_message" then
			os.queueEvent(event[1], event[2], event[3], event[4], event[5], event[6])
			--TODO: Provide event safe fsleep(t)
			return nil
		elseif event[1] == "timer" then
			return nil
		end
	end

	return self
end

return fcp
