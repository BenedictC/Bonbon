//
//  _AnyOptional.swift
//  Bonbon
//
//  Created by Benedict Cohen on 21/05/2026.
//



public protocol _AnyOptional {

    static var none: Self { get }
}

extension Optional: _AnyOptional { }
