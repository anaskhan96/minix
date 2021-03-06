; RUN: llc -march=amdgcn -mcpu=SI -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s
; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s
; RUN: llc -march=r600 -mcpu=redwood < %s | FileCheck -check-prefix=R600 -check-prefix=FUNC %s

; FUNC-LABEL: {{^}}uint_to_fp_i32_to_f32:
; R600-DAG: UINT_TO_FLT * T{{[0-9]+\.[XYZW]}}, KC0[2].Z

; SI: v_cvt_f32_u32_e32
; SI: s_endpgm
define void @uint_to_fp_i32_to_f32(float addrspace(1)* %out, i32 %in) {
  %result = uitofp i32 %in to float
  store float %result, float addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}uint_to_fp_v2i32_to_v2f32:
; R600-DAG: UINT_TO_FLT * T{{[0-9]+\.[XYZW]}}, KC0[2].W
; R600-DAG: UINT_TO_FLT * T{{[0-9]+\.[XYZW]}}, KC0[3].X

; SI: v_cvt_f32_u32_e32
; SI: v_cvt_f32_u32_e32
; SI: s_endpgm
define void @uint_to_fp_v2i32_to_v2f32(<2 x float> addrspace(1)* %out, <2 x i32> %in) {
  %result = uitofp <2 x i32> %in to <2 x float>
  store <2 x float> %result, <2 x float> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}uint_to_fp_v4i32_to_v4f32:
; R600: UINT_TO_FLT * T{{[0-9]+\.[XYZW], T[0-9]+\.[XYZW]}}
; R600: UINT_TO_FLT * T{{[0-9]+\.[XYZW], T[0-9]+\.[XYZW]}}
; R600: UINT_TO_FLT * T{{[0-9]+\.[XYZW], T[0-9]+\.[XYZW]}}
; R600: UINT_TO_FLT * T{{[0-9]+\.[XYZW], T[0-9]+\.[XYZW]}}

; SI: v_cvt_f32_u32_e32
; SI: v_cvt_f32_u32_e32
; SI: v_cvt_f32_u32_e32
; SI: v_cvt_f32_u32_e32
; SI: s_endpgm
define void @uint_to_fp_v4i32_to_v4f32(<4 x float> addrspace(1)* %out, <4 x i32> addrspace(1)* %in) {
  %value = load <4 x i32> addrspace(1) * %in
  %result = uitofp <4 x i32> %value to <4 x float>
  store <4 x float> %result, <4 x float> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}uint_to_fp_i64_to_f32:
; R600: UINT_TO_FLT
; R600: UINT_TO_FLT
; R600: MULADD_IEEE
; SI: v_cvt_f32_u32_e32
; SI: v_cvt_f32_u32_e32
; SI: v_mad_f32
; SI: s_endpgm
define void @uint_to_fp_i64_to_f32(float addrspace(1)* %out, i64 %in) {
entry:
  %0 = uitofp i64 %in to float
  store float %0, float addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}uint_to_fp_i1_to_f32:
; SI: v_cmp_eq_i32_e64 [[CMP:s\[[0-9]+:[0-9]\]]],
; SI-NEXT: v_cndmask_b32_e64 [[RESULT:v[0-9]+]], 0, 1.0, [[CMP]]
; SI: buffer_store_dword [[RESULT]],
; SI: s_endpgm
define void @uint_to_fp_i1_to_f32(float addrspace(1)* %out, i32 %in) {
  %cmp = icmp eq i32 %in, 0
  %fp = uitofp i1 %cmp to float
  store float %fp, float addrspace(1)* %out, align 4
  ret void
}

; FUNC-LABEL: {{^}}uint_to_fp_i1_to_f32_load:
; SI: v_cndmask_b32_e64 [[RESULT:v[0-9]+]], 0, 1.0
; SI: buffer_store_dword [[RESULT]],
; SI: s_endpgm
define void @uint_to_fp_i1_to_f32_load(float addrspace(1)* %out, i1 %in) {
  %fp = uitofp i1 %in to float
  store float %fp, float addrspace(1)* %out, align 4
  ret void
}
